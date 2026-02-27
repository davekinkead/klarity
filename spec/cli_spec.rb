require 'rspec'
require 'stringio'
require 'klarity'
require 'klarity/cli'

RSpec.describe Klarity::CLI do
  let(:fixtures_path) { File.expand_path('fixtures/sample_app', __dir__) }

  describe '#run' do
    context 'with valid directory' do
      it 'analyzes directory and outputs hash' do
        cli = described_class.new([fixtures_path])
        output = capture_output { cli.run }

        expect(output).to include('User')
        expect(output).to include('Order')
        expect(output).to include('PaymentService')
      end
    end

    context 'with --help flag' do
      it 'shows help message and exits' do
        cli = described_class.new(['--help'])
        output = capture_output { cli.run }

        expect(output).to include('Usage:')
        expect(output).to include('klarity <directory>')
        expect(output).to include('--exclude')
        expect(output).to include('--include')
      end
    end

    context 'with -h flag' do
      it 'shows help message and exits' do
        cli = described_class.new(['-h'])
        output = capture_output { cli.run }

        expect(output).to include('Usage:')
      end
    end

    context 'with --exclude option' do
      it 'passes exclusion pattern to analyzer' do
        allow(Klarity::FileScanner).to receive(:scan).and_return([])

        cli = described_class.new([fixtures_path, '--exclude', '*/services/*'])
        cli.run

        expect(Klarity::FileScanner).to have_received(:scan).with(
          fixtures_path,
          hash_including(exclude_patterns: array_including('*/services/*'))
        )
      end
    end

    context 'with --include option' do
      it 'passes inclusion pattern to analyzer' do
        allow(Klarity::FileScanner).to receive(:scan).and_return([])

        cli = described_class.new([fixtures_path, '--include', '**/*service.rb'])
        cli.run

        expect(Klarity::FileScanner).to have_received(:scan).with(
          fixtures_path,
          hash_including(include_patterns: array_including('**/*service.rb'))
        )
      end
    end

    context 'with non-existent directory' do
      it 'outputs error message' do
        cli = described_class.new(['/nonexistent/directory'])

        expect { capture_output { cli.run } }.to raise_error(SystemExit)
      end
    end

    context 'with no arguments' do
      it 'shows help and exits' do
        cli = described_class.new([])

        expect { capture_output { cli.run } }.to raise_error(SystemExit)
      end
    end

    context 'with unknown option' do
      it 'raises CLIError' do
        cli = described_class.new([fixtures_path, '--unknown'])

        expect { capture_output { cli.run } }.to raise_error(Klarity::CLIError)
      end
    end
  end

  def capture_output
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
