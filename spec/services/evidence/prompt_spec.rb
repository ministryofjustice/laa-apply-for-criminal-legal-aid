require 'rails_helper'

RSpec.describe Evidence::Prompt do
  let(:applicant) { instance_double(Applicant, has_nino: 'yes') }
  let(:partner) { instance_double(Partner) }
  let(:income) { instance_double(Income, client_owns_property: 'yes') }
  let(:outgoings) { instance_double(Outgoings, housing_payment_type: 'mortgage') }
  let(:capital) { instance_double(Capital, has_premium_bonds: 'yes', partner_has_premium_bonds: 'yes') }
  let(:kase) { nil }
  let(:include_partner?) { true }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      applicant:,
      partner:,
      income:,
      outgoings:,
      capital:,
      kase:
    )
  end

  let(:empty_ruleset) do
    Class.new(Evidence::Ruleset::Base) do
      def rules
        []
      end
    end
  end

  let(:wales_ruleset) do
    Class.new(Evidence::Ruleset::Base) do
      def rules
        [
          Evidence::Rules::ExampleRule1,
          Evidence::Rules::ExampleRule2Budget2024,
        ]
      end
    end
  end

  before do
    stub_const('EmptyRuleset', empty_ruleset)
    stub_const('WalesRuleset', wales_ruleset)

    Rails.root.glob('spec/fixtures/files/evidence/rules/*.rb') do |file|
      load file
    end

    allow(MeansStatus).to receive(:include_partner?).with(crime_application) { include_partner? }

    allow(crime_application).to receive_messages(
      :evidence_prompts => [],
      :evidence_prompts= => nil,
      :evidence_last_run_at => [],
      :evidence_last_run_at= => nil,
      :is_means_tested => 'yes',
      :save! => true
    )

    allow(applicant).to receive_messages(
      under18?: false,
    )
  end

  describe '#initialize' do
    context 'when ruleset is not supplied' do
      it 'uses Latest ruleset with same crime_application' do
        prompt = described_class.new(crime_application)

        expect(prompt.ruleset).to be_a Evidence::Ruleset::Latest
        expect(prompt.ruleset.crime_application).to eq prompt.crime_application
      end
    end

    context 'when custom ruleset is supplied' do
      it 'uses supplied ruleset' do
        custom_ruleset = WalesRuleset.new(crime_application, [])
        prompt = described_class.new(crime_application, custom_ruleset)

        expect(prompt.ruleset).to be_a WalesRuleset
        expect(prompt.ruleset.rules).to contain_exactly(
          Evidence::Rules::ExampleRule1,
          Evidence::Rules::ExampleRule2Budget2024
        )
      end
    end

    context 'with invalid parameters' do
      it 'raises exception' do
        expect { described_class.new(nil) }.to raise_exception ArgumentError, /CrimeApplication required/
        expect { described_class.new(crime_application, Object.new) }.to raise_exception Errors::InvalidRuleset
      end
    end
  end

  describe '#run!' do
    before do
      allow(crime_application).to receive(:save!).and_return true
    end

    it 'persists generated prompts' do # rubocop:disable RSpec/ExampleLength
      expected_prompts = [
        {
          id: 'ExampleRule1',
          group: :capital,
          ruleset: 'WalesRuleset',
          key: :example1,
          run: {
            client: { result: true, prompt: ['a bank statement for your client'] },
            partner: { result: true, prompt: ['a bank statement for the partner'] },
            other: { result: false, prompt: [] },
          }
        },
        {
          id: 'ExampleRule2Budget2024',
          group: :outgoings,
          ruleset: 'WalesRuleset',
          key: :example2,
          run: {
            client: { result: true, prompt: ['a birth certificate', 'a driving licence'] },
            partner: { result: false, prompt: [] },
            other: { result: false, prompt: [] },
          }
        },
      ]

      custom_ruleset = WalesRuleset.new(crime_application, [])
      now = Time.zone.local(2024, 10, 1, 13, 23, 55)

      travel_to now
      described_class.new(crime_application, custom_ruleset).run!
      travel_back

      expect(crime_application).to have_received(:evidence_prompts=).with(expected_prompts)
      expect(crime_application).to have_received(:evidence_last_run_at=).with(now)
    end
  end

  describe '#run' do
    before do
      allow(crime_application).to receive(:evidence_prompts=)
    end

    it 'does not persist generated prompts' do
      described_class.new(crime_application, WalesRuleset.new(crime_application)).run

      expect(crime_application).not_to have_received(:evidence_prompts=)
    end

    it 'generates results' do
      prompt = described_class.new(crime_application, WalesRuleset.new(crime_application)).run

      expect(prompt.results?).to be true
      expect(prompt.result_for?(group: :capital, persona: :client)).to be true
    end

    context 'with Latest ruleset' do
      it 'generates results' do
        ruleset = Evidence::Ruleset::Latest.new(crime_application, [:example1, :other_example])
        prompt = described_class.new(crime_application, ruleset).run

        expect(prompt.results.size).to eq 2
      end
    end

    context 'with Hydrated and versioned ruleset' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:outgoings) { instance_double(Outgoings, housing_payment_type: 'rent') }

      # NOTE: ExampleRule2 is the archived/old-version rule in /fixtures
      let(:persisted_evidence_prompts) do
        [
          {
            id: 'ExampleRule2',
            group: :outgoings,
            ruleset: 'Hydrated',
            key: :example2,
            run: {
              client: { result: true, prompt: ['this client rule is archived'] },
              partner: { result: false, prompt: [] },
              other: { result: false, prompt: [] },
            }
          },
          {
            id: 'ExampleOfOther',
            group: :none,
            ruleset: 'Hydrated',
            key: :other_example,
            run: {
              client: { result: true, prompt: ['your client\'s extra evidence'] },
              partner: { result: true, prompt: ['the partner\'s other evidence'] },
              other: { result: true, prompt: ['any useful information about your legal practice'] },
            }
          },
        ]
      end

      before do
        allow(crime_application).to receive(:evidence_prompts).and_return(persisted_evidence_prompts)
      end

      it 'generates results' do
        ruleset = Evidence::Ruleset::Hydrated.new(crime_application, [:example2, :other_example])
        prompt = described_class.new(crime_application, ruleset).run

        expect(prompt.results).to eq persisted_evidence_prompts
      end
    end
  end

  describe '#exempt?' do
    subject(:prompt) { described_class.new(crime_application) }

    context 'when there are no exempt reasons' do
      it 'returns false' do
        expect(prompt.exempt?).to be false
        expect(prompt.exempt_reasons).to be_empty
      end
    end

    context 'when the client is not means tested' do
      before do
        allow(crime_application).to receive(:is_means_tested).and_return 'no'
      end

      it 'returns true and sets the reason' do
        expect(prompt.exempt?).to be true
        expect(prompt.exempt_reasons).to contain_exactly(
          'it is not subject to the usual means or passported test'
        )
      end
    end

    context 'when the client is under 18' do
      before do
        allow(applicant).to receive(:under18?).and_return true
      end

      it 'returns true and sets the reason' do
        expect(prompt.exempt?).to be true
        expect(prompt.exempt_reasons).to contain_exactly(
          'your client was under 18 when the application was first made'
        )
      end
    end

    context 'when the client is in custody' do
      let(:kase) { instance_double(Case, is_client_remanded: 'yes') }

      it 'returns true and sets the reason' do
        expect(prompt.exempt?).to be true
        expect(prompt.exempt_reasons).to contain_exactly(
          'you have told us they are remanded in custody'
        )
      end
    end
  end

  describe '#required?' do
    context 'when there are results' do
      subject { described_class.new(crime_application, WalesRuleset.new(crime_application)).required? }

      it { is_expected.to be true }
    end

    context 'when there are no results' do
      subject { described_class.new(crime_application, EmptyRuleset.new(crime_application)).required? }

      it { is_expected.to be false }
    end
  end

  describe '#result_for?' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    subject(:prompt) { described_class.new(crime_application, ruleset).run }

    let(:ruleset) do
      Evidence::Ruleset::Latest.new(crime_application, [:example1, :other_example])
    end

    it 'returns true when available' do
      # ExampleRule1
      expect(prompt.result_for?(group: :capital, persona: :client)).to be true
      expect(prompt.result_for?(group: :capital, persona: :partner)).to be true

      # ExampleOfOther
      expect(prompt.result_for?(group: :none, persona: :client)).to be true
      expect(prompt.result_for?(group: :none, persona: :partner)).to be true
      expect(prompt.result_for?(group: :none, persona: :other)).to be true
    end

    it 'returns false when not available' do
      # ExampleRule1
      expect(prompt.result_for?(group: :capital, persona: :other)).to be false

      # ExampleOfOther shows groups for all 3 personas

      # Random
      expect(prompt.result_for?(group: :what, persona: :who)).to be false
    end
  end

  describe '#result_for' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    subject(:prompt) { described_class.new(crime_application, ruleset).run }

    let(:ruleset) do
      Evidence::Ruleset::Latest.new(crime_application, [:example1, :other_example])
    end

    it 'returns the matching rule entry list' do # rubocop:disable RSpec/ExampleLength
      # See Rule#to_h for format. Note the result is an array
      expected_result = [
        {
          id: 'ExampleRule1',
          group: :capital,
          ruleset: 'Latest',
          key: :example1,
          run: {
            client: {
              result: true,
              prompt: ['a bank statement for your client'],
            },
            partner: {
              result: true,
              prompt: ['a bank statement for the partner'],
            },
            other: {
              result: false,
              prompt: [],
            },
          }
        }
      ]

      # ExampleRule1
      expect(prompt.result_for(group: :capital, persona: :client)).to eq expected_result
    end
  end
end
