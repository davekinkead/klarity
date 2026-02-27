# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/klarity/detectors/references_detector'

RSpec.describe Klarity::ReferencesDetector do
  let(:detector) { described_class.new }

  describe '#detect' do
    it 'detects constant references' do
      code = <<~RUBY
        Service
      RUBY

      ast = Prism.parse(code).value
      const_node = ast.child_nodes.first.body.first

      result = detector.detect(const_node)
      expect(result).to eq(['Service'])
    end

    it 'detects namespaced constant references' do
      code = <<~RUBY
        Auth::Permissions
      RUBY

      ast = Prism.parse(code).value
      const_node = ast.child_nodes.first.body.first

      result = detector.detect(const_node)
      expect(result).to eq(['Auth::Permissions'])
    end

    it 'detects constants in arrays' do
      code = <<~RUBY
        [Service, Other]
      RUBY

      ast = Prism.parse(code).value
      array_node = ast.child_nodes.first.body.first

      result = detector.detect(array_node)
      expect(result).to contain_exactly('Service', 'Other')
    end

    it 'detects constants in method arguments' do
      code = <<~RUBY
        call(Service, Other)
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to contain_exactly('Service', 'Other')
    end

    it 'detects constants in chained calls' do
      code = <<~RUBY
        Service.call(Other)
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to contain_exactly('Service', 'Other')
    end

    it 'detects constants in method parameters' do
      code = <<~RUBY
        def foo(bar = Service, baz = Other)
        end
      RUBY

      ast = Prism.parse(code).value
      def_node = ast.child_nodes.first.body.first
      params_node = def_node.parameters

      result = detector.detect(params_node)
      expect(result).to contain_exactly('Service', 'Other')
    end

    it 'detects constants in required parameters' do
      code = <<~RUBY
        def foo(bar, baz)
        end
      RUBY

      ast = Prism.parse(code).value
      def_node = ast.child_nodes.first.body.first
      params_node = def_node.parameters

      result = detector.detect(params_node)
      expect(result).to be_empty
    end

    it 'returns empty for non-constant nodes' do
      code = <<~RUBY
        "string"
      RUBY

      ast = Prism.parse(code).value
      string_node = ast.child_nodes.first.body.first

      result = detector.detect(string_node)
      expect(result).to be_empty
    end
  end
end
