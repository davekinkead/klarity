# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/klarity/detectors/inheritance_detector'

RSpec.describe Klarity::InheritanceDetector do
  let(:detector) { described_class.new }

  describe '#detect' do
    it 'detects simple inheritance' do
      code = <<~RUBY
        class User < ApplicationRecord
        end
      RUBY

      ast = Prism.parse(code).value
      statements_node = ast.child_nodes.first
      class_node = statements_node.body.first

      result = detector.detect(class_node)
      expect(result).to eq(['ApplicationRecord'])
    end

    it 'detects namespaced inheritance' do
      code = <<~RUBY
        class Admin < Auth::User
        end
      RUBY

      ast = Prism.parse(code).value
      class_node = ast.child_nodes.first.body.first

      result = detector.detect(class_node)
      expect(result).to eq(['Auth::User'])
    end

    it 'returns empty array for class without superclass' do
      code = <<~RUBY
        class User
        end
      RUBY

      ast = Prism.parse(code).value
      class_node = ast.child_nodes.first.body.first

      result = detector.detect(class_node)
      expect(result).to eq([])
    end
  end
end
