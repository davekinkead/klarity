# frozen_string_literal: true

require 'prism'

module Klarity
  class Visitor < Prism::Visitor
    def initialize
      @results = {}
      @current_class = nil
      @current_namespace = []
      @messages = Set.new
      @inherits = []
      @mixins = Set.new
    end

    attr_reader :results

    def visit_class_node(node)
      previous_class = @current_class
      previous_messages = @messages
      previous_inherits = @inherits
      previous_mixins = @mixins

      name = extract_name(node.constant_path)
      @current_class = build_qualified_name(name)
      @messages = Set.new
      @inherits = []
      @mixins = Set.new

      if node.superclass
        superclass_name = extract_name(node.superclass)
        @inherits << superclass_name if superclass_name
      end

      super

      save_current_results

      @current_class = previous_class
      @messages = previous_messages
      @inherits = previous_inherits
      @mixins = previous_mixins
    end

    def visit_module_node(node)
      previous_namespace = @current_namespace.dup
      previous_class = @current_class
      previous_messages = @messages
      previous_inherits = @inherits
      previous_mixins = @mixins

      name = extract_name(node.constant_path)
      qualified_name = build_qualified_name(name)
      @current_namespace << name
      @current_class = qualified_name
      @messages = Set.new
      @inherits = []
      @mixins = Set.new

      super

      save_current_results

      @current_namespace = previous_namespace
      @current_class = previous_class
      @messages = previous_messages
      @inherits = previous_inherits
      @mixins = previous_mixins
    end

    def visit_call_node(node)
      return unless @current_class

      check_mixin_calls(node)

      check_array_include(node)

      receiver = extract_receiver(node)
      @messages.add(receiver) if receiver && !is_self_call?(receiver)

      super
    end

    def visit_def_node(node)
      return unless @current_class

      check_keyword_defaults(node.parameters)

      super
    end

    private

    def extract_name(node)
      case node
      when Prism::ConstantReadNode
        node.name.to_s
      when Prism::ConstantPathNode
        build_path(node)
      end
    end

    def build_qualified_name(name)
      return name if @current_namespace.empty?

      [*@current_namespace, name].join('::')
    end

    def build_path(node)
      parts = []
      current = node

      while current
        if current.is_a?(Prism::ConstantPathNode)
          parts.unshift(current.name.to_s) if current.name
          current = current.parent
        elsif current.is_a?(Prism::ConstantReadNode)
          parts.unshift(current.name.to_s)
          current = nil
        else
          current = nil
        end
      end

      parts.join('::')
    end

    def extract_receiver(node)
      receiver = node.receiver

      return nil unless receiver

      case receiver
      when Prism::SelfNode
        nil
      when Prism::ConstantReadNode
        receiver.name.to_s
      when Prism::ConstantPathNode
        build_path(receiver)
      end
    end

    def is_self_call?(_receiver)
      false
    end

    def check_mixin_calls(node)
      return unless %i[include extend prepend].include?(node.name)

      node.arguments&.arguments&.each do |arg|
        case arg
        when Prism::ConstantReadNode
          @mixins << arg.name.to_s
        when Prism::ConstantPathNode
          @mixins << build_path(arg)
        end
      end
    end

    def check_array_include(node)
      return unless node.name == :include?
      return unless node.receiver.is_a?(Prism::ArrayNode)

      node.receiver.elements.each do |element|
        case element
        when Prism::ConstantReadNode
          @messages << element.name.to_s
        when Prism::ConstantPathNode
          @messages << build_path(element)
        end
      end
    end

    def check_keyword_defaults(parameters)
      return unless parameters&.keywords

      parameters.keywords.each do |keyword_param|
        next unless keyword_param.is_a?(Prism::OptionalKeywordParameterNode)

        value = keyword_param.value
        next unless value

        extract_dependency_from_node(value)
      end
    end

    def extract_dependency_from_node(node)
      case node
      when Prism::CallNode
        receiver = extract_receiver(node)
        @messages << receiver if receiver && node.name == :new
      end
    end

    def save_current_results
      return unless @current_class

      @results[@current_class] = {
        messages: @messages.to_a,
        inherits: @inherits,
        mixins: @mixins.to_a,
        dynamic: false
      }
    end
  end
end
