# frozen_string_literal: true

require 'prism'
require_relative 'detectors/inheritance_detector'
require_relative 'detectors/mixins_detector'
require_relative 'detectors/messages_detector'
require_relative 'detectors/references_detector'
require_relative 'detectors/dynamic_detector'

module Klarity
  class Visitor < Prism::Visitor
    def initialize
      @results = {}
      @current_class = nil
      @current_namespace = []
      @messages = Set.new
      @inherits = []
      @mixins = Set.new
      @references = Set.new
      @dynamic = Set.new

      @inheritance_detector = InheritanceDetector.new
      @mixins_detector = MixinsDetector.new
      @messages_detector = MessagesDetector.new
      @references_detector = ReferencesDetector.new
      @dynamic_detector = DynamicDetector.new
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

      @inherits.concat(@inheritance_detector.detect(node))

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

      @references.merge(@references_detector.detect(node))

      @mixins.merge(@mixins_detector.detect(node))

      @messages.merge(@messages_detector.detect(node))

      @dynamic.merge(@dynamic_detector.detect(node))

      super
    end

    def visit_def_node(node)
      return unless @current_class

      @references.merge(@references_detector.detect(node.parameters)) if node.parameters

      @dynamic.merge(@dynamic_detector.detect(node))

      super
    end

    def visit_when_node(node)
      return unless @current_class

      node.conditions.each { |cond| @references.merge(@references_detector.detect(cond)) }

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
