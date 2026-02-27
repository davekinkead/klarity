# frozen_string_literal: true

require 'prism'

module Klarity
  class BaseDetector
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

    def extract_name(node)
      case node
      when Prism::ConstantReadNode
        node.name.to_s
      when Prism::ConstantPathNode
        build_path(node)
      end
    end
  end
end
