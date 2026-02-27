# frozen_string_literal: true

module Klarity
  class DependencyGraph
    DEFAULT_DEPENDENCIES = {
      inherits: [],
      mixins: [],
      messages: [],
      dynamic: false
    }.freeze

    def initialize
      @graph = {}
    end

    def add_class(name, dependencies = {})
      @graph[name] ||= DEFAULT_DEPENDENCIES.dup

      dependencies.each do |key, value|
        if %i[inherits includes messages].include?(key)
          @graph[name][key] |= Array(value)
        else
          @graph[name][key] = value
        end
      end
    end

    def to_h
      @graph.dup
    end

    def merge!(other_graph)
      other_graph.to_h.each do |name, dependencies|
        add_class(name, dependencies)
      end
    end
  end
end
