require 'rspec'
require 'klarity'
require 'klarity/cli'
require 'json'

RSpec.describe Klarity::CLI do
  let(:fixtures_path) { File.expand_path('fixtures/sample_app', __dir__) }

  describe '#run' do
    it 'analyzes directory and returns hash' do
      cli = described_class.new([fixtures_path])
      result = cli.run

      expect(result).to be_a(Hash)
      expect(result.keys).to include('User', 'Order')
    end

    it 'returns JSON when --json flag is present' do
      cli = described_class.new([fixtures_path, '--json'])
      result = cli.run

      expect(result).to be_a(String)
      parsed = JSON.parse(result)
      expect(parsed).to be_a(Hash)
      expect(parsed.keys).to include('User', 'Order')
    end

    it 'returns USAGE for help flags' do
      cli = described_class.new(['--help'])
      result = cli.run

      expect(result).to include('Usage:')
      expect(result).to include('klarity <directory>')
      expect(result).to include('--json')
    end

    it 'returns USAGE for -h flag' do
      cli = described_class.new(['-h'])
      result = cli.run

      expect(result).to include('Usage:')
    end

    it 'returns USAGE when no arguments' do
      cli = described_class.new([])
      result = cli.run

      expect(result).to include('Usage:')
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

    it 'raises error for non-existent directory' do
      cli = described_class.new(['/nonexistent'])

      expect { cli.run }.to raise_error(Klarity::CLIError)
    end
  end
end
