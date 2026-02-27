# frozen_string_literal: true

require 'prism'

module Klarity
  class Visitor < Prism::Visitor
    DYNAMIC_METHODS = %i[send public_send __send__ method_missing define_method
                         instance_variable_get instance_variable_set
                         const_get const_set respond_to_missing?
                         respond_to? method].freeze

    def initialize
      @results = {}
      @current_class = nil
      @current_namespace = []
      @messages = Set.new
      @inherits = []
      @mixins = Set.new
      @references = Set.new
      @dynamic = Set.new
    end

    attr_reader :results

    def visit_class_node(node)
      previous_class = @current_class
      previous_messages = @messages
      previous_inherits = @inherits
      previous_mixins = @mixins
      previous_references = @references
      previous_dynamic = @dynamic

      name = extract_name(node.constant_path)
      @current_class = build_qualified_name(name)
      @messages = Set.new
      @inherits = []
      @mixins = Set.new
      @references = Set.new
      @dynamic = Set.new

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
      @references = previous_references
      @dynamic = previous_dynamic
    end

    def visit_module_node(node)
      previous_namespace = @current_namespace.dup
      previous_class = @current_class
      previous_messages = @messages
      previous_inherits = @inherits
      previous_mixins = @mixins
      previous_references = @references
      previous_dynamic = @dynamic

      name = extract_name(node.constant_path)
      qualified_name = build_qualified_name(name)
      @current_namespace << name
      @current_class = qualified_name
      @messages = Set.new
      @inherits = []
      @mixins = Set.new
      @references = Set.new
      @dynamic = Set.new

      super

      save_current_results

      @current_namespace = previous_namespace
      @current_class = previous_class
      @messages = previous_messages
      @inherits = previous_inherits
      @mixins = previous_mixins
      @references = previous_references
      @dynamic = previous_dynamic
    end

    def visit_call_node(node)
      return unless @current_class

      track_constants(node.receiver)
      track_constants_in_arguments(node.arguments)

      track_mixin_calls(node)
      track_dynamic_calls(node)

      receiver = extract_receiver(node)
      @messages.add(receiver) if receiver && !is_self_call?(receiver)

      super
    end

    def visit_def_node(node)
      return unless @current_class

      track_constants(node.parameters)
      track_dynamic_method_definitions(node)

      super
    end

    def visit_when_node(node)
      return unless @current_class

      node.conditions.each { |cond| track_constants(cond) }

      super
    end

    private

    def track_constants(node)
      return unless node

      case node
      when Prism::ConstantReadNode
        @references << node.name.to_s
      when Prism::ConstantPathNode
        @references << build_path(node)
      when Prism::ArrayNode
        node.elements.each { |el| track_constants(el) }
      when Prism::ArgumentsNode
        node.arguments&.each { |arg| track_constants(arg) }
      when Prism::CallNode
        track_constants(node.receiver)
        node.arguments&.arguments&.each { |arg| track_constants(arg) }
      end
    end

    def track_constants_in_arguments(arguments_node)
      return unless arguments_node

      if arguments_node.respond_to?(:arguments)
        arguments_node.arguments.each { |arg| track_constants(arg) }
      elsif arguments_node.respond_to?(:requireds)
        track_constants_in_parameters(arguments_node)
      end
    end

    def track_mixin_calls(node)
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

    def track_dynamic_calls(node)
      return unless DYNAMIC_METHODS.include?(node.name)

      @dynamic << node.name.to_s
    end

    def track_dynamic_method_definitions(node)
      return unless DYNAMIC_METHODS.include?(node.name)

      @dynamic << node.name.to_s
    end

    def track_constants_in_parameters(parameters_node)
      parameters_node.requireds&.each { |p| track_constants(p) }
      parameters_node.optionals&.each { |p| track_constants(p) }
      parameters_node.rest && track_constants(parameters_node.rest)
      parameters_node.posts&.each { |p| track_constants(p) }
      parameters_node.keywords&.each { |p| track_constants(p) }
      parameters_node.keyword_rest && track_constants(parameters_node.keyword_rest)
      parameters_node.block && track_constants(parameters_node.block)
    end

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
      when Prism::LocalVariableReadNode, Prism::InstanceVariableReadNode,
           Prism::ClassVariableReadNode, Prism::GlobalVariableReadNode
        receiver.name.to_s
      end
    end

    def is_self_call?(_receiver)
      false
    end

    def save_current_results
      return unless @current_class

      @results[@current_class] = {
        messages: @messages.to_a,
        inherits: @inherits,
        mixins: @mixins.to_a,
        references: @references.to_a,
        dynamic: @dynamic.to_a
      }
    end
  end
end
