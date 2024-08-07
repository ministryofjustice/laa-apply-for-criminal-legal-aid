require 'rails_helper'

RSpec.describe Evidence::Rule do
  include_context 'serializable application'

  before do
    capital.has_premium_bonds = 'yes'
    capital.partner_has_premium_bonds = 'yes'
    outgoings.housing_payment_type = 'mortgage'
    income.client_owns_property = 'yes'
    applicant.has_nino = 'yes'
    stub_const('OffsideRule', offside_rule)
    stub_const('BarebonesRule', barebones_rule)

    Rails.root.glob('spec/fixtures/files/evidence/rules/*.rb') do |file|
      load file
    end
  end

  let(:offside_rule) do
    Class.new(Evidence::Rule) do
      include Evidence::RuleDsl

      key :offside_rule
      archived false
      group :none

      other do |crime_application|
        crime_application.is_a? Adapters::Structs::CrimeApplication
      end
    end
  end

  let(:barebones_rule) do
    Class.new(Evidence::Rule) do
      include Evidence::RuleDsl

      # NOTE: deliberately missing `key`, `archived`
    end
  end

  describe 'constants' do
    it 'defines valid GROUPS' do
      expect(described_class::GROUPS).to contain_exactly(:income, :outgoings, :capital, :none)
    end

    it 'defines valid PERSONAS' do
      expect(described_class::PERSONAS).to contain_exactly(:client, :partner, :other)
    end
  end

  describe '.for?' do
    context 'when the key is defined' do
      it 'returns true if the provided key matches the class key' do
        expect(OffsideRule.for?(:offside_rule)).to be true
      end

      it 'returns false if the provided key does not match the class key' do
        expect(OffsideRule.for?(:red_card_rule)).to be false
      end
    end

    context 'when the key is not defined' do
      it 'returns default UNKNOWN_KEY' do
        expect(BarebonesRule.key).to eq :UNKNOWN_KEY
        expect(BarebonesRule.for?(:UNKNOWN_KEY)).to be true
      end
    end
  end

  describe '.timestamp' do
    subject(:rule) do
      Evidence::Rules::ExampleRule2.new(crime_application)
    end

    it 'returns the date from filename' do
      expected_datetime = DateTime.parse('8th Nov 2023 09:15:55')

      expect(Evidence::Rules::ExampleRule2.timestamp).to eq expected_datetime
    end

    it 'returns the current date if filename does not contain valid date' do
      now = Time.zone.local(2024, 10, 1, 13, 23, 55)
      travel_to now

      expect(Evidence::Rules::BadRuleDefinition.timestamp).to eq now

      travel_back
    end
  end

  describe '.active?' do
    it 'returns true when rule is not archived' do
      expect(OffsideRule.active?).to be true
    end

    it 'returns true when attribute not specified' do
      expect(BarebonesRule.active?).to be true
    end

    it 'returns false when rule is archived' do
      expect(Evidence::Rules::BadRuleDefinition.active?).to be false
    end
  end

  describe '.valid?' do
    context 'when passing basic validity check' do
      it 'passes' do
        expect(OffsideRule.valid?).to be true
        expect(OffsideRule.errors).to be_empty
      end
    end

    context 'when failing basic validity check' do
      it 'populates errors list' do
        expect(Evidence::Rules::BadRuleDefinition.valid?).to be false
        expect(Evidence::Rules::BadRuleDefinition.errors.first)
          .to eq('Invalid group workplace defined')
      end
    end
  end

  describe '#initialize' do
    it 'initializes with a crime application draft submission' do
      rule = BarebonesRule.new(crime_application)

      expect(rule.crime_application).to be_a(Adapters::Structs::CrimeApplication)
      expect(rule.crime_application.id).to eq(crime_application.id)
    end
  end

  # TODO: Not sure whether `id` should just be called `klass`. Storing the
  # fully qualified class name including module could mean allowing Rule definitions
  # from different modules to be executed, but currently assuming all Rule definitions
  # belong to Evidence::Rules module
  describe '#id' do
    it 'as the class name without module' do
      expect(OffsideRule.new(crime_application).id).to eq('OffsideRule')
    end
  end

  describe '#key' do
    it 'as defined by the DSL' do
      expect(OffsideRule.new(crime_application).key).to eq(:offside_rule)
    end

    it 'is :UNKNOWN_KEY when not defined' do
      expect(Evidence::Rules::BadRuleDefinition.new(crime_application).key).to eq(:UNKNOWN_KEY)
    end
  end

  describe '#group' do
    it 'as defined by the DSL' do
      expect(Evidence::Rules::BadRuleDefinition.new(crime_application).group).to eq(:workplace)
    end

    it 'is :none when not defined' do
      expect(BarebonesRule.new(crime_application).group).to eq(:none)
    end
  end

  describe '#archived?' do
    it 'as defined by the DSL' do
      expect(OffsideRule.new(crime_application).archived?).to be false
    end
  end

  describe '#to_h' do
    subject { Evidence::Rules::ExampleRule1.new(crime_application).to_h }

    let(:expected_hash) do
      {
        id: 'ExampleRule1',
        group: :capital,
        ruleset: nil, # Populated when Prompt is generated
        key: :example1,
        run: {
          client: { result: true, prompt: ['a bank statement for your client'] },
          partner: { result: true, prompt: ['a bank statement for the partner'] },
          other: { result: false, prompt: [] },
        }
      }
    end

    it 'only generates prompts for `true` predicates' do
      expect(subject).to eq expected_hash
    end
  end

  describe 'predicates' do
    let(:example_rule1) { Evidence::Rules::ExampleRule1.new(crime_application) }
    let(:example_bad) { Evidence::Rules::BadRuleDefinition.new(crime_application) }

    context 'when defined' do
      it 'evaluates the predicate', :aggregate_failures do
        expect(example_rule1.client_predicate).to be true
        expect(example_rule1.partner_predicate).to be true
        expect(OffsideRule.new(crime_application).other_predicate).to be true
      end
    end

    context 'when not defined' do
      it 'evaluates to false', :aggregate_failures do
        offside_rule = OffsideRule.new(crime_application)

        expect(OffsideRule.client).to be_nil
        expect(offside_rule.client_predicate).to be false

        expect(OffsideRule.partner).to be_nil
        expect(offside_rule.partner_predicate).to be false

        expect(Evidence::Rules::ExampleRule1.other).to be_nil
        expect(example_rule1.other_predicate).to be false
      end
    end

    context 'when predicate evaluates to anything except true or false' do
      it 'raises error', :aggregate_failures do
        expect { example_bad.client_predicate }.to raise_exception Errors::UnsupportedPredicate
        expect { example_bad.partner_predicate }.to raise_exception Errors::UnsupportedPredicate
        expect { example_bad.other_predicate }.to raise_exception Errors::UnsupportedPredicate
      end
    end
  end

  describe 'rules interface' do
    let!(:rules) do
      Evidence::Rules.constants.map { |klass| "Evidence::Rules::#{klass}".constantize }
    end

    it 'must load rule definitions' do # rubocop:disable RSpec/ExampleLength
      expected_klasses = [
        Evidence::Rules::NationalInsuranceNumber,

        Evidence::Rules::ChildMaintenanceCosts,
        Evidence::Rules::HousingCosts,
        Evidence::Rules::CouncilTaxPayments,
        Evidence::Rules::ChildcareCosts,
        Evidence::Rules::SalariedEmployee,
        Evidence::Rules::BenefitsRecipient,
        Evidence::Rules::SelfAssessed,
        Evidence::Rules::SelfEmployed,
        Evidence::Rules::BenefitsInKind,
        Evidence::Rules::PrivatePensionIncome,
        Evidence::Rules::MaintenanceIncome,
        Evidence::Rules::InterestAndInvestments,
        Evidence::Rules::RentalIncome,
        Evidence::Rules::AnyOtherIncome,
        Evidence::Rules::TrustFund,
        Evidence::Rules::BankAccounts,
        Evidence::Rules::BuildingSocietyAccounts,
        Evidence::Rules::CashIsa,
        Evidence::Rules::NationalSavingsAccount,
        Evidence::Rules::CashInvestments,
        Evidence::Rules::PremiumBonds,
        Evidence::Rules::SavingsCerts,
        Evidence::Rules::StocksAndGilts,
        Evidence::Rules::OwnShares,
        Evidence::Rules::PepPlans,
        Evidence::Rules::ShareIsa,
        Evidence::Rules::UnitTrusts,
        Evidence::Rules::InvestmentBonds,
        Evidence::Rules::OtherLumpSums,
        Evidence::Rules::LostJob,
        Evidence::Rules::RestraintOrFreezingOrder,

        # Includes test rules in /fixtures
        Evidence::Rules::ExampleRule1,
        Evidence::Rules::ExampleRule2,
        Evidence::Rules::ExampleRule2Budget2023,
        Evidence::Rules::ExampleRule2Budget2024,
        Evidence::Rules::ExampleRule2Budget2025,
        Evidence::Rules::BadRuleDefinition,
        Evidence::Rules::ExampleOfOther,
      ]

      expect(rules).to match_array(expected_klasses)
    end

    it 'must inherit from Evidence::Rule' do
      instantiated = rules.map(&:new)

      expect(instantiated.all?(described_class)).to be true
    end

    it 'must have a key' do
      expect(rules.map(&:key).all?(&:present?)).to be true
    end

    it 'has a timestamped filename' do
      filenames = Rails.root.join('app/services/evidence/rules/*')

      timestamped = Dir.glob(filenames).map do |filepath|
        filepath.match?(%r{/(\d{14})_\w*.\.rb})
      end

      expect(timestamped.all?).to be true
    end

    it 'has a valid timestamp' do
      timestamped = rules.all? do |rule|
        rule.timestamp.is_a?(DateTime)
      end

      expect(timestamped).to be true
    end
  end
end
