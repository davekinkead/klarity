# frozen_string_literal: true

require_relative 'base_detector'

module Klarity
  class MessagesDetector < BaseDetector
    def detect(call_node)
      receiver = extract_receiver(call_node)
      receiver && !is_self_call?(receiver) ? [receiver] : []
    end

    private

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
  end
end
