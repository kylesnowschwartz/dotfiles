#!/usr/bin/env ruby
# frozen_string_literal: true

require 'claude_hooks'
require 'open3'
require 'shellwords'

# Auto Format Handler
#
# PURPOSE: Automatically format/lint files after Write, Edit, or MultiEdit operations
# DESIGN: Lightweight, obvious, maintainable using claude_hooks DSL patterns
# ALIGNMENT: Mirrors pre-commit configuration for consistency
#
# SUPPORTED FORMATTERS:
# - Ruby: RuboCop with auto-correct (-A flag)
# - Markdown: markdownlint with --fix (matching pre-commit rules)
# - Shell: shfmt with 2-space indentation (matching pre-commit args)
# - Lua: stylua with custom configuration (160 column width, Unix line endings, etc.)
# - Rust: rustfmt with default configuration
# - Python: black with default configuration, isort for import sorting
# - YAML: yamlfmt with default configuration, prettier as fallback
# - JavaScript/TypeScript: prettier with default configuration

class AutoFormatHandler < ClaudeHooks::PostToolUse
  def call
    log "Auto-format handler triggered for #{tool_name}"

    # Early returns for invalid conditions - keep it obvious
    return output_data unless should_process_tool?
    return output_data unless file_path_available?
    return output_data unless formatting_enabled?
    return output_data if should_skip_file?

    # Core formatting logic
    perform_formatting

    output_data
  end

  private

  def should_process_tool?
    file_modification_tools.include?(tool_name) && tool_successful?
  end

  def file_modification_tools
    %w[Write Edit MultiEdit]
  end

  def tool_successful?
    # Simple, clear success detection using DSL accessors
    return false if tool_response&.dig('error')
    return false if tool_response&.dig('success') == false
    return false if tool_response&.dig('exit_code')&.nonzero?

    true
  end

  def file_path_available?
    return true if current_file_path && File.exist?(current_file_path)

    log "File path not available or doesn't exist: #{current_file_path}", level: :warn
    false
  end

  def current_file_path
    @current_file_path ||= tool_input&.dig('file_path')
  end

  def formatting_enabled?
    # Use claude_hooks config helpers instead of custom JSON loading
    enabled = config.get_config_value('AUTO_FORMAT_ENABLED', 'enabled', true)

    log 'Auto-formatting disabled by configuration' unless enabled

    enabled
  end

  def should_skip_file?
    return false unless current_file_path

    relative_path = relative_file_path

    # Check against simple, obvious skip patterns
    if skip_patterns.any? { |pattern| matches_skip_pattern?(relative_path, pattern) }
      log "Skipping #{relative_path} - matches ignore pattern"
      return true
    end

    false
  end

  def relative_file_path
    # Use claude_hooks cwd helper instead of Dir.pwd
    File.expand_path(current_file_path).sub("#{cwd}/", '')
  end

  def skip_patterns
    @skip_patterns ||= load_skip_patterns
  end

  def load_skip_patterns
    patterns = default_skip_patterns

    # Try to load .claudeignore from project
    claudeignore_path = project_path_for('.claudeignore')
    if claudeignore_path && File.exist?(claudeignore_path)
      patterns += load_ignore_file(claudeignore_path)
      log "Loaded ignore patterns from #{claudeignore_path}"
    end

    # Try to load from home directory
    home_claudeignore = home_path_for('.claudeignore')
    if File.exist?(home_claudeignore)
      patterns += load_ignore_file(home_claudeignore)
      log "Loaded ignore patterns from #{home_claudeignore}"
    end

    patterns
  end

  def default_skip_patterns
    %w[
      node_modules/
      dist/
      build/
      .git/
      *.min.js
      *.min.css
      vendor/
      tmp/
      .bundle/
    ]
  end

  def load_ignore_file(file_path)
    File.readlines(file_path, chomp: true)
        .reject { |line| line.strip.empty? || line.start_with?('#') }
        .map(&:strip)
  rescue StandardError => e
    log "Error loading ignore file #{file_path}: #{e.message}", level: :error
    []
  end

  def matches_skip_pattern?(file_path, pattern)
    # Simplified pattern matching - obvious and maintainable
    if pattern.end_with?('/')
      # Directory pattern
      file_path.start_with?(pattern[0..-2])
    elsif pattern.include?('*')
      # Simple glob pattern using Ruby's built-in File.fnmatch
      File.fnmatch(pattern, file_path)
    else
      # Exact match or basename match
      file_path == pattern || File.basename(file_path) == pattern
    end
  end

  def perform_formatting
    formatter = detect_formatter
    unless formatter
      log "No formatter available for #{current_file_path}"
      return
    end

    log "Formatting #{current_file_path} with #{formatter[:name]}"

    result = run_formatter(formatter)

    if result[:success]
      log "Successfully formatted #{current_file_path}"
      add_success_feedback(formatter[:name])
    else
      log "Formatting failed: #{result[:error]}", level: :error
      add_error_feedback(formatter[:name], result[:error])
    end
  end

  def detect_formatter
    extension = File.extname(current_file_path).downcase

    # Simplified formatter detection - mirrors pre-commit configuration
    case extension
    when '.rb'
      command_available?('rubocop') ? { name: 'RuboCop', command: 'rubocop', args: ['-A'] } : nil
    when '.md'
      if command_available?('markdownlint')
        {
          name: 'markdownlint',
          command: 'markdownlint',
          args: [
            '--fix',
            '--disable',
            'MD013,MD041,MD026,MD012,MD024' # Match pre-commit disabled rules
          ]
        }
      end
    when '.sh', '.bash'
      if command_available?('shfmt')
        {
          name: 'shfmt',
          command: 'shfmt',
          args: ['-w', '-i', '2'] # Match pre-commit args: 2-space indentation
        }
      end
    when '.lua'
      if command_available?('stylua')
        {
          name: 'stylua',
          command: 'stylua',
          args: [
            '--column-width', '160',
            '--line-endings', 'Unix',
            '--indent-type', 'Spaces',
            '--indent-width', '2',
            '--quote-style', 'AutoPreferSingle',
            '--call-parentheses', 'None'
          ]
        }
      end
    when '.rs'
      command_available?('rustfmt') ? { name: 'rustfmt', command: 'rustfmt', args: [] } : nil
    when '.py'
      detect_python_formatter
    when '.yml', '.yaml'
      detect_yaml_formatter
    when '.js', '.jsx', '.ts', '.tsx', '.json'
      detect_js_formatter
    end
  end

  def detect_js_formatter
    # Try eslint first (yarn-based, then global)
    if yarn_project? && command_available?('yarn') && command_available?('eslint')
      { name: 'yarn eslint', command: 'yarn', args: ['eslint', '--fix'] }
    elsif command_available?('eslint')
      { name: 'eslint', command: 'eslint', args: ['--fix'] }
    # Fallback to prettier (yarn-based, then global)
    elsif yarn_project? && command_available?('yarn') && command_available?('prettier')
      { name: 'yarn prettier', command: 'yarn', args: ['prettier', '--write'] }
    elsif command_available?('prettier')
      { name: 'prettier', command: 'prettier', args: ['--write'] }
    end
  end

  def detect_yaml_formatter
    if command_available?('yamlfmt')
      { name: 'yamlfmt', command: 'yamlfmt', args: ['-w'] }
    elsif command_available?('prettier')
      { name: 'prettier', command: 'prettier', args: ['--write', '--parser', 'yaml'] }
    end
  end

  def detect_python_formatter
    # Ruff-only approach: automatically uses existing Black/isort/flake8 configs
    project_dir = find_project_root

    # Check for local Ruff first (virtual environment)
    if local_command_available?('ruff', project_dir)
      {
        name: 'ruff (local)',
        command: find_local_command('ruff', project_dir),
        args: ['format']
      }
    # Fallback to global Ruff
    elsif command_available?('ruff')
      {
        name: 'ruff (global)',
        command: 'ruff',
        args: ['format']
      }
    else
      # No Ruff available - log helpful message
      log 'No Ruff formatter found. Install with: pip install ruff'
      log 'Ruff automatically uses existing Black, isort, and flake8 configurations'
      nil
    end
  end

  def yarn_project?
    # Check for yarn.lock in current directory or walk up to find it
    current_dir = File.dirname(current_file_path)
    while current_dir != '/'
      return true if File.exist?(File.join(current_dir, 'yarn.lock'))

      current_dir = File.dirname(current_dir)
    end
    false
  end

  def command_available?(command)
    # Cache command availability to avoid repeated system calls
    @command_cache ||= {}

    return @command_cache[command] if @command_cache.key?(command)

    @command_cache[command] = system("which #{command} > /dev/null 2>&1")
  end

  def local_command_available?(command, project_dir)
    # Check for command in local virtual environment first
    @local_command_cache ||= {}
    cache_key = "#{project_dir}:#{command}"

    return @local_command_cache[cache_key] if @local_command_cache.key?(cache_key)

    # Check common venv locations
    venv_paths = [
      File.join(project_dir, 'venv', 'bin', command),
      File.join(project_dir, '.venv', 'bin', command),
      File.join(project_dir, 'env', 'bin', command),
      File.join(project_dir, '.env', 'bin', command)
    ]

    local_available = venv_paths.any? { |path| File.executable?(path) }
    @local_command_cache[cache_key] = local_available || command_available?(command)
  end

  def find_project_root
    # Walk up from current file to find project root indicators
    current_dir = File.dirname(current_file_path)

    while current_dir != '/'
      # Look for common project root indicators
      return current_dir if [
        'pyproject.toml', 'setup.py', 'setup.cfg', '.git',
        'requirements.txt', 'Pipfile', 'poetry.lock'
      ].any? { |indicator| File.exist?(File.join(current_dir, indicator)) }

      current_dir = File.dirname(current_dir)
    end

    # Fallback to file's directory
    File.dirname(current_file_path)
  end

  def find_local_command(command, project_dir)
    venv_paths = [
      File.join(project_dir, 'venv', 'bin', command),
      File.join(project_dir, '.venv', 'bin', command),
      File.join(project_dir, 'env', 'bin', command),
      File.join(project_dir, '.env', 'bin', command)
    ]

    venv_paths.find { |path| File.executable?(path) }
  end

  def run_formatter(formatter)
    # Store original content to detect changes
    original_content = File.read(current_file_path)

    result = run_standard_formatter(formatter)

    # Handle post_command for formatters like black+isort
    if result[:success] && formatter[:post_command]
      post_result = run_post_command(formatter[:post_command])
      result[:success] = post_result[:success]
      result[:error] = post_result[:error] unless post_result[:success]
    end

    # Check if changes were made and report
    if result[:success]
      new_content = File.read(current_file_path)
      result[:changes_made] = original_content != new_content
    end

    result
  rescue StandardError => e
    { success: false, error: e.message }
  end

  def run_standard_formatter(formatter)
    command_parts = [formatter[:command]] + formatter[:args] + [current_file_path]
    command = command_parts.map { |part| Shellwords.escape(part) }.join(' ')

    log "Running: #{command}"

    stdout_err, status = Open3.capture2e(command)

    if status.success?
      { success: true, output: stdout_err }
    else
      { success: false, error: stdout_err.strip }
    end
  end

  def run_post_command(command)
    command_parts = [command, current_file_path]
    command_string = command_parts.map { |part| Shellwords.escape(part) }.join(' ')

    log "Running post-command: #{command_string}"

    stdout_err, status = Open3.capture2e(command_string)

    if status.success?
      { success: true, output: stdout_err }
    else
      { success: false, error: stdout_err.strip }
    end
  end

  def add_success_feedback(formatter_name)
    # Use output_data hash directly - obvious and DSL-idiomatic
    output_data['feedback'] ||= []
    output_data['feedback'] << "✓ Auto-formatted with #{formatter_name}"
  end

  def add_error_feedback(formatter_name, error)
    output_data['feedback'] ||= []
    output_data['feedback'] << "⚠ Auto-formatting failed (#{formatter_name}): #{error}"
  end
end

# Testing support - claude_hooks DSL pattern
if __FILE__ == $PROGRAM_NAME
  ClaudeHooks::CLI.test_runner(AutoFormatHandler) do |input_data|
    input_data['tool_name'] = 'Write'
    input_data['tool_input'] = { 'file_path' => '/tmp/test.rb' }
    input_data['tool_response'] = { 'success' => true }
    input_data['session_id'] = 'test-session-01'

    # Create a test file for demonstration
    File.write('/tmp/test.rb', "def hello\nputs 'world'\nend")
  end
end
