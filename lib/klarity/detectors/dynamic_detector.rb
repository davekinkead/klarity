# frozen_string_literal: true

require_relative 'base_detector'

module Klarity
  class DynamicDetector < BaseDetector
    DYNAMIC_METHODS = %i[
      send
      public_send
      __send__
      method_missing
      define_method
      instance_variable_get
      instance_variable_set
      const_get
      const_set
      respond_to_missing?
      respond_to?
      method
    ].freeze

    def detect(call_node)
      DYNAMIC_METHODS.include?(call_node.name) ? [call_node.name.to_s] : []
    end
  end
end
