require 'rspec'
require 'klarity'

RSpec.describe Klarity do
  let(:fixtures_path) { File.expand_path('fixtures/sample_app', __dir__) }

  describe '.analyze' do
    it 'analyzes a directory and returns a dependency graph with messages' do
      result = described_class.analyze(fixtures_path)

      expect(result).to be_a(Hash)

      expect(result['User']).to be_a(Hash)
      expect(result['User'][:messages]).to include('Order')
      expect(result['User'][:messages]).to include('EmailService')
      expect(result['User'][:messages]).to include('PaymentService')
      expect(result['User'][:messages]).to include('Database')

      expect(result['Order']).to be_a(Hash)
      expect(result['Order'][:messages]).to include('PaymentService')
      expect(result['Order'][:messages]).to include('NotificationService')
      expect(result['Order'][:messages]).to include('Validator')
      expect(result['Order'][:messages]).to include('Database')

      expect(result['PaymentService']).to be_a(Hash)
      expect(result['PaymentService'][:messages]).to include('PaymentGateway')
      expect(result['PaymentService'][:messages]).to include('AuditService')

      expect(result['EmailService']).to be_a(Hash)
      expect(result['EmailService'][:messages]).to include('SMTPClient')

      expect(result['Database']).to be_a(Hash)
      expect(result['Database'][:messages]).to include('Connection')
    end

    it 'deduplicates messages - one entry per unique object type' do
      result = described_class.analyze(fixtures_path)

      expect(result['Order'][:messages].count('PaymentService')).to eq(1)
      expect(result['PaymentService'][:messages].count('PaymentGateway')).to eq(1)
      expect(result['Database'][:messages].count('Connection')).to eq(1)
    end

    it 'handles implicit receiver as self' do
      result = described_class.analyze(fixtures_path)

      expect(result['User'][:messages]).not_to include('User')
      expect(result['Order'][:messages]).not_to include('Order')
    end

    it 'includes all empty arrays for other keys' do
      result = described_class.analyze(fixtures_path)

      expect(result['User'][:inherits]).to eq([])
      expect(result['User'][:includes]).to eq([])
      expect(result['User'][:dynamic]).to eq(false)
    end
  end
end
