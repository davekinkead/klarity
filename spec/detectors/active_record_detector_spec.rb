# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/klarity/detectors/active_record_detector'

RSpec.describe Klarity::ActiveRecordDetector do
  let(:detector) { described_class.new }

  describe '#detect' do
    it 'detects belongs_to association' do
      code = <<~RUBY
        belongs_to :user
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['User'])
    end

    it 'detects has_many association' do
      code = <<~RUBY
        has_many :orders
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['Order'])
    end

    it 'detects has_one association' do
      code = <<~RUBY
        has_one :profile
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['Profile'])
    end

    it 'detects has_and_belongs_to_many association' do
      code = <<~RUBY
        has_and_belongs_to_many :tags
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['Tag'])
    end

    it 'handles association with class_name option' do
      code = <<~RUBY
        belongs_to :author, class_name: 'Person'
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['Person'])
    end

    it 'handles association with class_name option (double quotes)' do
      code = <<~RUBY
        has_many :comments, class_name: "Comment"
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['Comment'])
    end

    it 'handles multiple associations' do
      code = <<~RUBY
        has_many :orders
        has_many :products
      RUBY

      ast = Prism.parse(code).value
      stmts_node = ast.child_nodes.first

      result1 = detector.detect(stmts_node.body[0])
      result2 = detector.detect(stmts_node.body[1])

      expect(result1).to eq(['Order'])
      expect(result2).to eq(['Product'])
    end

    it 'singularizes has_many with regular plural' do
      code = <<~RUBY
        has_many :items
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['Item'])
    end

    it 'singularizes has_many ending in -ies' do
      code = <<~RUBY
        has_many :categories
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['Category'])
    end

    it 'singularizes has_many ending in -ses' do
      code = <<~RUBY
        has_many :addresses
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['Address'])
    end

    it 'handles underscore association names' do
      code = <<~RUBY
        belongs_to :order_item
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['OrderItem'])
    end

    it 'handles plural underscore association names' do
      code = <<~RUBY
        has_many :order_items
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['OrderItem'])
    end

    it 'returns empty for non-association calls' do
      code = <<~RUBY
        validates :name, presence: true
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to be_empty
    end
  end
end
