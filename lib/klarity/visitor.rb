# frozen_string_literal: true

require 'prism'

module Klarity
  class Visitor < Prism::Visitor
    def initialize
      @results = {}
      @current_class = nil
      @current_namespace = []
      @messages = Set.new
    end

    attr_reader :results

    def visit_class_node(node)
      previous_class = @current_class
      previous_messages = @messages

      name = extract_name(node.constant_path)
      @current_class = build_qualified_name(name)
      @messages = Set.new

      super

      save_current_results

      @current_class = previous_class
      @messages = previous_messages
    end

    def visit_module_node(node)
      previous_namespace = @current_namespace.dup
      previous_class = @current_class
      previous_messages = @messages

      name = extract_name(node.constant_path)
      qualified_name = build_qualified_name(name)
      @current_namespace << name
      @current_class = qualified_name
      @messages = Set.new

      super

      save_current_results

      @current_namespace = previous_namespace
      @current_class = previous_class
      @messages = previous_messages
    end

    def visit_call_node(node)
      return unless @current_class

      receiver = extract_receiver(node)
      @messages.add(receiver) if receiver && !is_self_call?(receiver)

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

    def save_current_results
      return unless @current_class

      @results[@current_class] = {
        messages: @messages.to_a,
        inherits: [],
        includes: [],
        dynamic: false
      }
    end
  end
end
