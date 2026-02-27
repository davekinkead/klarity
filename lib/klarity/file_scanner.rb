# frozen_string_literal: true

module Klarity
  class FileScanner
    DEFAULT_EXCLUDE_PATTERNS = [
      'vendor/**/*',
      'node_modules/**/*',
      '.git/**/*',
      'tmp/**/*',
      'log/**/*'
    ].freeze

    def self.scan(directory, **options)
      new(**options).scan(directory)
    end

    def initialize(exclude_patterns: [], include_patterns: [], **_options)
      @exclude_patterns = DEFAULT_EXCLUDE_PATTERNS + exclude_patterns
      @include_patterns = include_patterns
    end

    def scan(directory)
      Dir.glob(File.join(directory, '**/*.rb')).select do |file|
        include_file?(file)
      end
    end

    private

    def include_file?(file)
      return false if excluded?(file)

      @include_patterns.empty? || included?(file)
    end

    def excluded?(file)
      @exclude_patterns.any? { |pattern| File.fnmatch(pattern, file) }
    end

    def included?(file)
      @include_patterns.any? { |pattern| File.fnmatch(pattern, file) }
    end
  end
end
