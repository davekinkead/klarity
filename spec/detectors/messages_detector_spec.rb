# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/klarity/detectors/messages_detector'

RSpec.describe Klarity::MessagesDetector do
  let(:detector) { described_class.new }

  describe '#detect' do
    it 'detects messages to constants' do
      code = <<~RUBY
        Service.call
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['Service'])
    end

    it 'detects messages to namespaced constants' do
      code = <<~RUBY
        Auth::Permissions.check
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['Auth::Permissions'])
    end

    it 'detects messages to instance variables' do
      code = <<~RUBY
        @user.call
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq(['@user'])
    end

    it 'detects messages to local variables' do
      code = <<~RUBY
        user = nil
        user.call
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body[1]

      result = detector.detect(call_node)
      expect(result).to eq(['user'])
    end

    it 'ignores implicit self calls' do
      code = <<~RUBY
        call
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq([])
    end

    it 'ignores explicit self calls' do
      code = <<~RUBY
        self.call
      RUBY

      ast = Prism.parse(code).value
      call_node = ast.child_nodes.first.body.first

      result = detector.detect(call_node)
      expect(result).to eq([])
    end
  end
end
