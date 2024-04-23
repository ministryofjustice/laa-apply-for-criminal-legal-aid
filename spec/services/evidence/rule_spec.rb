require 'rails_helper'

RSpec.describe Evidence::Rule do
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

  let(:offside_rule) do
    Class.new(Evidence::Rule) do
      include Evidence::RuleDsl

      key :offside_rule
      archived false
      group :none

      other do |crime_application|
        crime_application.is_a? RSpec::Mocks::InstanceVerifyingDouble
      end
    end
  end

  let(:barebones_rule) do
    Class.new(Evidence::Rule) do
      include Evidence::RuleDsl

      # NOTE: deliberately missing `key`, `archived`
    end
  end

  before do
    stub_const('OffsideRule', offside_rule)
    stub_const('BarebonesRule', barebones_rule)

    Rails.root.glob('spec/fixtures/files/evidence/rules/*.rb') do |file|
      load file
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
    it 'initializes with a crime application' do
      rule = BarebonesRule.new(crime_application)

      expect(rule.crime_application).to eq(crime_application)
    end
  end

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

        expect(offside_rule.client_predicate).to be false
        expect(offside_rule.partner_predicate).to be false
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
    let(:definitions) do
      Rails.root.join('app/services/evidence/rules/*')
    end

    let!(:klasses) do
      @_klasses ||= Evidence::Ruleset::Runner.load_rules!

      Evidence::Rules.constants
    end

    let!(:rules) do
      klasses.map { |klass| "Evidence::Rules::#{klass}".constantize }
    end

    it 'must load rule definitions' do
      expected_klasses = [
        Evidence::Rules::IncomeSalary0a,
        Evidence::Rules::IncomeSalary0b,
        Evidence::Rules::IncomeSalary0aRevised,
        Evidence::Rules::IncomeBenefitBasicCheck,
        Evidence::Rules::IncomeSalary0aNewButArchived,
        Evidence::Rules::NationalInsuranceProof,
        Evidence::Rules::P60TaxApril2024,
        Evidence::Rules::P60TaxApril2025,
        Evidence::Rules::P45ProofApril2024,
        Evidence::Rules::P45ProofApril2025,

        # Includes test rules in /fixtures
        Evidence::Rules::ExampleRule1,
        Evidence::Rules::ExampleRule2,
        Evidence::Rules::ExampleRule2Budget2024,
        Evidence::Rules::BadRuleDefinition,
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
      timestamped = Dir.glob(definitions).map do |filepath|
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
