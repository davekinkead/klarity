require 'rspec'
require 'klarity'
require 'klarity/cli'
require_relative 'spec_helper'

RSpec.describe Klarity::CLI do
  let(:fixtures_path) { File.expand_path('fixtures/sample_app', __dir__) }

  around do |example|
    original_stdout = $stdout
    original_stderr = $stderr
    $stdout = StringIO.new
    $stderr = StringIO.new
    example.run
  ensure
    $stdout = original_stdout
    $stderr = original_stderr
  end

  describe '#run' do
    it 'analyzes directory and returns hash' do
      cli = described_class.new([fixtures_path])
      result = cli.run

      expect(result).to be_a(Hash)
      expect(result.keys).to include('User', 'Order')
    end

    it 'passes options to analyzer' do
      allow(Klarity::FileScanner).to receive(:scan).and_return([])

      cli = described_class.new([fixtures_path, '--exclude', '*/services/*'])
      cli.run

      expect(Klarity::FileScanner).to have_received(:scan).with(
        fixtures_path,
        hash_including(exclude_patterns: array_including('*/services/*'))
      )
    end

    it 'returns nil for help flags' do
      expect(described_class.new(['--help']).run).to be_nil
      expect(described_class.new(['-h']).run).to be_nil
    end

    it 'raises error for non-existent directory' do
      cli = described_class.new(['/nonexistent'])
      expect { cli.run }.to raise_error(Klarity::CLIError)
    end
  end
end
