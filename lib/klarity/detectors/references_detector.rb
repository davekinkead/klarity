# frozen_string_literal: true

require_relative 'base_detector'

module Klarity
  class ReferencesDetector < BaseDetector
    def initialize
      @references = Set.new
    end

    def detect(node)
      return [] unless node

      case node
      when Prism::ConstantReadNode
        [node.name.to_s]
      when Prism::ConstantPathNode
        [build_path(node)]
      when Prism::ArrayNode
        node.elements.flat_map { |el| detect(el) }
      when Prism::ArgumentsNode
        detect_in_arguments(node)
      when Prism::CallNode
        detect_in_call(node)
      when Prism::ParametersNode
        detect_in_parameters(node)
      when Prism::OptionalParameterNode
        detect(node.value) if node.value
      when Prism::OptionalKeywordParameterNode
        detect(node.value) if node.value
      when Prism::RequiredParameterNode, Prism::RequiredKeywordParameterNode,
           Prism::RestParameterNode, Prism::KeywordRestParameterNode, Prism::BlockParameterNode,
           Prism::ForwardingParameterNode, Prism::NoKeywordsParameterNode
        []
      else
        []
      end
    end

    private

    def detect_in_arguments(arguments_node)
      if arguments_node.respond_to?(:arguments)
        arguments_node.arguments.flat_map { |arg| detect(arg) }
      elsif arguments_node.respond_to?(:requireds)
        detect_in_parameters(arguments_node)
      else
        []
      end
    end

    def detect_in_call(call_node)
      result = []
      result.concat(detect(call_node.receiver)) if call_node.receiver
      result.concat(detect_in_arguments(call_node.arguments)) if call_node.arguments
      result
    end

    def detect_in_parameters(parameters_node)
      result = []
      result.concat(parameters_node.requireds.flat_map { |p| detect(p) }) if parameters_node.requireds
      result.concat(parameters_node.optionals.flat_map { |p| detect(p) }) if parameters_node.optionals
      result.concat(detect(parameters_node.rest)) if parameters_node.rest
      result.concat(parameters_node.posts.flat_map { |p| detect(p) }) if parameters_node.posts
      result.concat(parameters_node.keywords.flat_map { |p| detect(p) }) if parameters_node.keywords
      result.concat(detect(parameters_node.keyword_rest)) if parameters_node.keyword_rest
      result.concat(detect(parameters_node.block)) if parameters_node.block
      result
    end
  end
end
