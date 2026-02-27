# frozen_string_literal: true

require_relative 'base_detector'

module Klarity
  class InheritanceDetector < BaseDetector
    def detect(class_node)
      return [] unless class_node.superclass

      superclass_name = extract_name(class_node.superclass)
      superclass_name ? [superclass_name] : []
    end
  end
end
