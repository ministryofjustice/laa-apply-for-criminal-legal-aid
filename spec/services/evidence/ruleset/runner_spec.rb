require 'rails_helper'

RSpec.describe Evidence::Ruleset::Runner do
  let(:applicant) { instance_double(Applicant, has_nino: 'yes') }
  let(:income) { instance_double(Income, client_owns_property: 'yes') }
  let(:outgoings) { instance_double(Outgoings, housing_payment_type: 'mortgage') }
  let(:capital) { instance_double(Capital, has_premium_bonds: 'yes') }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      applicant:,
      income:,
      outgoings:,
      capital:,
    )
  end

  before do
    described_class.load_rules!
  end

  describe '#initialize' do
    context 'with invalid parameters' do
      it 'raises exception' do
        expect { described_class.new(nil) }.to raise_exception ArgumentError, /CrimeApplication required/
      end
    end
  end

  describe '#ruleset' do
    subject { described_class.new(crime_application).ruleset }

    context 'with unsubmitted application' do
      before do
        allow(crime_application).to receive_messages(
          resubmission?: false,
          evidence_prompts: []
        )
      end

      it { is_expected.to be_a Evidence::Ruleset::Latest }
    end

    context 'with submitted application without evidence_prompts' do
      before do
        allow(crime_application).to receive_messages(
          resubmission?: true,
          evidence_prompts: []
        )
      end

      it { is_expected.to be_a Evidence::Ruleset::Latest }
    end

    context 'with submitted application with previous run' do
      before do
        persisted_evidence_prompt = [
          {
            'id' => 'NationalInsuranceProof',
            'key' => 'national_insurance_32',
            'run' => {
              'other' => {
                'prompt' => ['their National Insurance number'],
                'result' => true
              },
              'client' => {
                'prompt' => [],
                'result' => false
              },
              'partner' => {
                'prompt' => [],
                'result' => false
              }
            },
            'group' => 'none',
            'ruleset' => 'Hydrated'
          }
        ]

        allow(crime_application).to receive_messages(
          resubmission?: true,
          evidence_prompts: persisted_evidence_prompt
        )
      end

      it { is_expected.to be_a Evidence::Ruleset::Hydrated }
    end
  end

  describe '#keys' do
    subject { described_class.new(crime_application) }

    before do
      allow(crime_application).to receive_messages(evidence_prompts: [])
    end

    it 'has Rule definition for each key' do
      rules = Evidence::Rules.constants.map do |klass|
        "Evidence::Rules::#{klass}".constantize
      end

      actual = subject.keys.map do |key|
        rules.select { |rule| rule.for?(key) }
      end

      expect(actual.all?).to be true
    end
  end
end
