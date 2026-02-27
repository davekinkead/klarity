# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/klarity/detectors/mixins_detector'

RSpec.describe Klarity::MixinsDetector do
  let(:detector) { described_class.new }

  describe '#detect' do
    it 'detects include statements' do
      code = <<~RUBY
        include ActiveModel::Validations
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['ActiveModel::Validations'])
    end

    it 'detects extend statements' do
      code = <<~RUBY
        extend ActiveModel::Naming
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['ActiveModel::Naming'])
    end

    it 'detects prepend statements' do
      code = <<~RUBY
        prepend Auditable
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['Auditable'])
    end

    it 'detects multiple mixins' do
      code = <<~RUBY
        include Foo, Bar::Baz
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to contain_exactly('Foo', 'Bar::Baz')
    end

    it 'returns empty array for non-mixin calls' do
      code = <<~RUBY
        puts "hello"
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq([])
    end
  end
end
