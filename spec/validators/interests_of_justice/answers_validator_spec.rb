require 'rails_helper'

RSpec.describe InterestsOfJustice::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record) }

  let(:record) { crime_application }
  let(:crime_application) { instance_double(CrimeApplication) }
  let(:errors) { double(:errors) }
  let(:non_means_tested) { false }
  let(:cifc?) { false }
  let(:ioj) { Ioj.new }
  let(:ioj_passported?) { false }

  before do
    allow(crime_application).to receive_messages(
      cifc?: cifc?,
      ioj: ioj,
      ioj_passported?: ioj_passported?
    )
  end

  describe '#applicable?' do
    subject(:applicable) { validator.applicable? }

    it { is_expected.to be true }

    context 'when cifc' do
      let(:cifc?) { true }

      it { is_expected.to be false }
    end
  end

  describe '#complete?' do
    subject(:complete?) { validator.complete? }

    let(:types) { [] }

    before do
      allow(ioj).to receive_messages(
        types:
      )
    end

    it { is_expected.to be false }

    context 'when IoJ passported' do
      let(:ioj_passported?) { true }

      it { is_expected.to be true }
    end

    context 'when no IoJ types selected' do
      it { is_expected.to be false }
    end

    context 'when IoJ types and justifications given' do
      let(:types) { %w[reputation understanding] }

      before do
        allow(ioj).to receive_messages(
          reputation_justification: 'reputation text',
          understanding_justification: 'understanding text'
        )
      end

      it { is_expected.to be true }
    end

    context 'when IoJ types selected but justifications missing' do
      let(:types) { %w[reputation understanding] }

      before do
        allow(ioj).to receive_messages(
          reputation_justification: 'reputation text',
          understanding_justification: ''
        )
      end

      it { is_expected.to be false }
    end
  end

  describe '#validate' do
    subject(:validate) { validator.validate }

    let(:ioj) { Ioj.new(types: ['reputation']) }

    context 'when incomplete' do
      it 'adds errors to the IoJ record' do
        validate
        expect(ioj.errors.added?(:ioj, :incomplete)).to be true
      end
    end

    context 'when complete' do
      before do
        ioj.reputation_justification = 'justification details'
      end

      it 'does not add an error' do
        validate
        expect(ioj.errors.added?(:ioj, :incomplete)).to be false
      end
    end
  end
end
