# frozen_string_literal: true

require 'json'
require_relative 'web_generator'

module Klarity
  class CLIError < Error; end

  class CLI
    USAGE = <<~USAGE
      Usage: klarity <directory> [options]

      Analyzes Ruby code in given directory and outputs dependency graph.

      Options:
        --exclude PATTERN   Glob pattern to exclude files
        --include PATTERN   Glob pattern to include files
        --json              Output as JSON
        --html              Generate interactive HTML visualization
        --help, -h          Show this help message

      Examples:
        klarity ./app
        klarity ~/projects/myapp/app --exclude "*/concerns/*"
        klarity ./app --json
        klarity ./app --html
    USAGE

    def initialize(args)
      @args = args
      @options = {}
      @json_output = false
      @html_output = false
    end

    def run
      return USAGE if @args.include?('--help') || @args.include?('-h')

      return USAGE if @args.empty?

      directory = File.expand_path(@args.first)

      raise CLIError, "Directory not found: #{directory}" unless File.directory?(directory)

      parse_options!

      result = Klarity.analyze(directory, **@options)

      return generate_html(result) if @html_output

      @json_output ? JSON.generate(result) : result
    end

    private

    def parse_options!
      @args.shift

      while @args.first&.start_with?('-')
        option = @args.shift

        case option
        when '--exclude'
          @options[:exclude_patterns] ||= []
          @options[:exclude_patterns] << @args.shift
        when '--include'
          @options[:include_patterns] ||= []
          @options[:include_patterns] << @args.shift
        when '--json'
          @json_output = true
        when '--html'
          @html_output = true
        else
          raise CLIError, "Unknown option: #{option}"
        end
      end
    end

    def generate_html(data)
      file_path = WebGenerator.generate(data)

      puts "Analysis saved to: #{file_path}"
      puts 'Opening in browser...'

      open_browser(file_path)

      file_path
    end

    def open_browser(file_path)
      case RbConfig::CONFIG['host_os']
      when /darwin|mac os/
        system("open '#{file_path}'")
      when /linux/
        system("xdg-open '#{file_path}'")
      when /mswin|mingw|cygwin/
        system("start '' '#{file_path}'")
      end
    end
  end
end
