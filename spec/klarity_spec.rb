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

    it 'includes all empty arrays for other keys when no inheritance/mixins' do
      result = described_class.analyze(fixtures_path)

      expect(result['Order'][:inherits]).to eq([])
      expect(result['Order'][:mixins]).to eq([])
      expect(result['Order'][:dynamic]).to eq(false)
    end

    it 'captures dependencies from array include? checks in references' do
      result = described_class.analyze(fixtures_path)

      expect(result['ArrayIncludeCheck']).to be_a(Hash)
      expect(result['ArrayIncludeCheck'][:references]).to include('User')
      expect(result['ArrayIncludeCheck'][:references]).to include('Order')
      expect(result['ArrayIncludeCheck'][:references]).to include('PaymentService')
      expect(result['ArrayIncludeCheck'][:references]).to include('PaymentGateway')
      expect(result['ArrayIncludeCheck'][:references]).to include('AuditService')
    end

    it 'captures dependencies from default values in keyword arguments in references' do
      result = described_class.analyze(fixtures_path)

      expect(result['UserService']).to be_a(Hash)
      expect(result['UserService'][:references]).to include('UserRepository')
      expect(result['UserService'][:references]).to include('NotificationService')
      expect(result['UserService'][:references]).to include('EmailValidator')
    end

    it 'tracks all message receivers including variables' do
      result = described_class.analyze(fixtures_path)

      expect(result['UserService'][:messages]).to include('@user_repository')
      expect(result['UserService'][:messages]).to include('@notifier')
      expect(result['UserService'][:messages]).to include('validator')
      expect(result['UserService'][:messages]).to include('@user_repository')
    end
  end
end
