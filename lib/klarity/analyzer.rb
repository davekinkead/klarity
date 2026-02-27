# frozen_string_literal: true

require 'prism'

module Klarity
  class Analyzer
    def self.analyze(directory, **options)
      new(**options).analyze(directory)
    end

    def initialize(**options)
      @options = options
    end

    def analyze(directory)
      files = FileScanner.scan(directory, **@options)

      graph = DependencyGraph.new

      files.each do |file|
        analyze_file(file, graph)
      rescue StandardError => e
        warn "Error processing #{file}: #{e.message}"
      end

      graph.to_h
    end

    private

    def analyze_file(file, graph)
      source = File.read(file)
      parse_result = Prism.parse(source)

      visitor = Visitor.new
      visitor.visit(parse_result.value)

      visitor.results.each do |class_name, dependencies|
        graph.add_class(class_name, dependencies)
      end
    end
  end
end
