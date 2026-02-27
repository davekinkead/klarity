# frozen_string_literal: true

require_relative 'base_detector'

module Klarity
  class MixinsDetector < BaseDetector
    MIXIN_METHODS = %i[include extend prepend].freeze

    def detect(call_node)
      return [] unless MIXIN_METHODS.include?(call_node.name)

      extract_mixin_names(call_node)
    end

    private

    def extract_mixin_names(call_node)
      return [] unless call_node.arguments

      call_node.arguments.arguments.filter_map do |arg|
        extract_name(arg)
      end
    end
  end
end
