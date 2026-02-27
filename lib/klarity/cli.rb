# frozen_string_literal: true

require 'json'

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
        --help, -h          Show this help message

      Examples:
        klarity ./app
        klarity ~/projects/myapp/app --exclude "*/concerns/*"
        klarity ./app --json
    USAGE

    def initialize(args)
      @args = args
      @options = {}
      @json_output = false
    end

    def run
      return USAGE if @args.include?('--help') || @args.include?('-h')

      return USAGE if @args.empty?

      directory = File.expand_path(@args.first)

      raise CLIError, "Directory not found: #{directory}" unless File.directory?(directory)

      parse_options!

      result = Klarity.analyze(directory, **@options)

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
        else
          raise CLIError, "Unknown option: #{option}"
        end
      end
    end
  end
end
