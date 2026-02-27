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
      parse_options!

      if @args.empty?
        show_help
        exit 1
      end

      directory = File.expand_path(@args.first)

      raise CLIError, "Directory not found: #{directory}" unless File.directory?(directory)

      result = Klarity.analyze(directory, **@options)
      print_result(result)
    end

    private

    def parse_options!
      while @args.first&.start_with?('-')
        option = @args.shift

        case option
        when '--help', '-h'
          show_help
          exit 0
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

    def show_help
      puts USAGE
    end

    def print_result(result)
      puts result.inspect
    end
  end
end
