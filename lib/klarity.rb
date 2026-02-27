# frozen_string_literal: true

require_relative 'klarity/version'
require_relative 'klarity/analyzer'
require_relative 'klarity/file_scanner'
require_relative 'klarity/dependency_graph'
require_relative 'klarity/visitor'

module Klarity
  class Error < StandardError; end

  def self.analyze(directory, **options)
    Analyzer.analyze(directory, **options)
  end
end
