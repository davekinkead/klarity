# frozen_string_literal: true

module Klarity
  class CLIError < Error; end

  class CLI
    USAGE = <<~USAGE
      Usage: klarity <directory> [options]

      Analyzes Ruby code in the given directory and outputs dependency graph.

      Options:
        --exclude PATTERN   Glob pattern to exclude files
        --include PATTERN   Glob pattern to include files
        --help, -h          Show this help message

      Examples:
        klarity ./app
        klarity ~/projects/myapp/app --exclude "*/concerns/*"
    USAGE

    def initialize(args)
      @args = args
      @options = {}
    end

    def run
      return USAGE if @args.include?('--help') || @args.include?('-h')

      return USAGE if @args.empty?

      directory = File.expand_path(@args.first)

      raise CLIError, "Directory not found: #{directory}" unless File.directory?(directory)

      parse_options!

      Klarity.analyze(directory, **@options)
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
        else
          raise CLIError, "Unknown option: #{option}"
        end
      end
    end
  end
end
