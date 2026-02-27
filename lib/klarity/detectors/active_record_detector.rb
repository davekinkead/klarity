# frozen_string_literal: true

require_relative 'base_detector'

module Klarity
  class ActiveRecordDetector < BaseDetector
    ASSOCIATION_METHODS = %i[
      belongs_to
      has_many
      has_one
      has_and_belongs_to_many
    ].freeze

    def detect(call_node)
      return [] unless ASSOCIATION_METHODS.include?(call_node.name)

      extract_associations(call_node)
    end

    private

    def extract_associations(call_node)
      return [] unless call_node.arguments

      args = call_node.arguments.arguments

      symbol_arg = args.find { |arg| arg.is_a?(Prism::SymbolNode) }
      hash_arg = args.find { |arg| arg.is_a?(Prism::HashNode) || arg.is_a?(Prism::KeywordHashNode) }

      if hash_arg
        class_name = extract_class_name_from_hash(hash_arg)
        return [remove_quotes(class_name)] if class_name
      end

      return [infer_class_name(symbol_arg.value.to_s)] if symbol_arg

      []
    end

    def extract_association_with_options(node)
      association_name = nil
      class_name = nil

      if node.is_a?(Prism::CallNode) && node.arguments
        association_name = extract_first_symbol(node.arguments)
        class_name = extract_class_name_option(node.arguments)
      elsif node.is_a?(Prism::KeywordHashNode)
        class_name = extract_class_name_from_hash(node)
      end

      return nil unless association_name || class_name

      if class_name
        remove_quotes(class_name)
      elsif association_name
        infer_class_name(association_name)
      end
    end

    def extract_first_symbol(arguments_node)
      return nil unless arguments_node&.arguments

      first_arg = arguments_node.arguments.first
      return nil unless first_arg.is_a?(Prism::SymbolNode)

      first_arg.value.to_s
    end

    def extract_hash_options(arguments_node)
      return nil unless arguments_node&.arguments

      arguments_node.arguments.find { |arg| arg.is_a?(Prism::HashNode) || arg.is_a?(Prism::KeywordHashNode) }
    end

    def extract_class_name_option(arguments_node)
      return nil unless arguments_node&.arguments

      hash_node = arguments_node.arguments.find { |arg| arg.is_a?(Prism::KeywordHashNode) }
      return nil unless hash_node

      extract_class_name_from_hash(hash_node)
    end

    def extract_class_name_from_hash(hash_node)
      return nil unless hash_node&.elements

      class_name_element = hash_node.elements.find do |elem|
        next false unless elem.is_a?(Prism::AssocNode)

        key = elem.key
        key.is_a?(Prism::SymbolNode) && key.value == 'class_name'
      end

      return nil unless class_name_element

      value = class_name_element.value
      return nil unless value.is_a?(Prism::StringNode)

      value.unescaped
    end

    def remove_quotes(string)
      string&.gsub(/^['"]|['"]$/, '')
    end

    def infer_class_name(association_name)
      return nil unless association_name

      singular_name = singularize(association_name)
      camelize(singular_name)
    end

    def singularize(word)
      return word unless word.end_with?('s')

      simple_rules = [
        [/ies$/, 'y'],
        [/ves$/, 'f'],
        [/ses$/, 's'],
        [/xes$/, 'x'],
        [/ches$/, 'ch'],
        [/shes$/, 'sh'],
        [/les$/, 'le'],
        [/mes$/, 'me'],
        [/nes$/, 'ne'],
        [/pes$/, 'pe'],
        [/tes$/, 'te'],
        [/es$/, ''],
        [/s$/, '']
      ]

      simple_rules.each do |pattern, replacement|
        return word.gsub(pattern, replacement) if word.match?(pattern)
      end

      word
    end

    def camelize(word)
      word.split('_').map(&:capitalize).join
    end
  end
end
