# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/klarity/detectors/dynamic_detector'

RSpec.describe Klarity::DynamicDetector do
  let(:detector) { described_class.new }

  describe '#detect' do
    Klarity::DynamicDetector::DYNAMIC_METHODS.each do |method_name|
      it "detects #{method_name} calls" do
        code = "#{method_name}(:foo)"
        ast = Prism.parse(code).value
        call_node = ast.child_nodes.first.body.first

        result = detector.detect(call_node)
        expect(result).to eq([method_name.to_s])
      end
    end

    it 'returns empty for non-dynamic methods' do
      code = 'regular_method(:foo)'
      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to be_empty
    end

    it 'detects dynamic methods with receivers' do
      code = 'obj.send(:foo)'
      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['send'])
    end
  end
end
