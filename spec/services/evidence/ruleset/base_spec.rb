require 'rails_helper'

RSpec.describe Evidence::Ruleset::Base do
  let(:crime_application) do
    instance_double(CrimeApplication, evidence_prompts: [])
  end

  before do
    Rails.root.glob('spec/fixtures/files/evidence/rules/*.rb') do |file|
      load file
    end
  end

  describe '#initialize' do
    it 'should be used as abstract class' do
      expect { described_class.new(crime_application).rules }.to raise_exception NotImplementedError
    end

    context 'with crime_application only' do
      it 'uses default KEYS' do
        expect(described_class.new(crime_application).keys).to eq Evidence::Ruleset::Runner::KEYS
      end
    end

    context 'with custom keys' do
      it 'uses custom keys' do
        expect(described_class.new(crime_application, [:example2]).keys).to contain_exactly(:example2)
      end
    end
  end

  describe '#keys' do
    # Custom `keys` acts like a scope
    it 'allows child classes to only load appropriate Rule definitions' do
      latest_ruleset = Evidence::Ruleset::Latest.new(crime_application, [:example2])

      expect(latest_ruleset.rules).to contain_exactly(Evidence::Rules::ExampleRule2Budget2024)
    end
  end
end
