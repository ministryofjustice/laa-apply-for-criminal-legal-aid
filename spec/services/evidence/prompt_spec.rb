require 'rails_helper'

RSpec.describe Evidence::Prompt do
  Evidence::Ruleset::Runner.load_rules!

  subject { described_class.new(ruleset) }

  let(:crime_application) do
    CrimeApplication.new(applicant: Applicant.new(has_nino: has_nino))
  end

  let(:has_nino) { 'yes' }

  describe '#initialize' do
    context 'with valid ruleset' do
      let(:ruleset) do
        Evidence::Ruleset::Latest.new(crime_application, [:national_insurance_32])
      end

      before do
        subject
      end

      it 'has a crime_application' do
        expect(subject.crime_application).to eq(ruleset.crime_application)
      end

      it 'immediately generates results' do
        expect(subject.results.size).to eq 1
      end

      it 'saves last run at time' do
        expect(crime_application.evidence_last_run_at).to be_a ActiveSupport::TimeWithZone
      end

      it 'saves executed ruleset' do
        expect(crime_application.evidence_ruleset).to eq ['Evidence::Rules::NationalInsuranceProof']
      end

      it 'saves generated prompts' do
        expected_prompts = [
          {
            'rule_id' => 'NationalInsuranceProof',
            'group' => 'none',
            'results' => { 'client' => false, 'partner' => false, 'other' => true }
          }
        ]

        expect(crime_application.evidence_prompts).to eq expected_prompts
      end
    end

    context 'when CrimeApplication is nil' do
      let(:ruleset) do
        Evidence::Ruleset::Latest.new(nil, [])
      end

      it 'raises exception' do
        expect { subject }.to raise_exception ArgumentError, /CrimeApplication required/
      end
    end

    context 'when ruleset is not enumerable' do
      let(:ruleset) do
        Class.new do
          def crime_application
            CrimeApplication.new
          end
        end
      end

      it 'raises exception' do
        expect { subject }.to raise_exception ArgumentError, /Ruleset must provide rule definitions/
      end
    end

    context 'with Latest ruleset' do
    end

    context 'with Hydrated ruleset' do
    end

    context 'with Base ruleset' do
    end
  end

  describe '#results' do
    let(:ruleset) do
      Evidence::Ruleset::Latest.new(crime_application, [:national_insurance_32])
    end

    it 'is an array' do
      expect(subject.results).to be_a Array
    end

    it 'contains rule_id' do
      expect(subject.results.all? { |result| result.key?(:rule_id) }).to be true
    end
  end

  describe '#client', :skip do
  end

  describe '#partner', :skip do
  end

  describe '#other' do
    let(:ruleset) do
      Evidence::Ruleset::Latest.new(crime_application, [:national_insurance_32])
    end

    let(:expected_result) do
      [
        {
          rule_id: 'NationalInsuranceProof',
          group: :none,
          results: { client: false, other: true, partner: false }
        }
      ]
    end

    it 'has other results when predicate true' do
      expect(subject.other?).to be true
      expect(subject.other).to eq expected_result
    end
  end
end
