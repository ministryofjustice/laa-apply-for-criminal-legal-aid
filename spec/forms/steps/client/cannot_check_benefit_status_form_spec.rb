require 'rails_helper'

RSpec.describe Steps::Client::CannotCheckBenefitStatusForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: applicant_record,
    }.merge(
      form_attributes
    )
  end

  let(:form_attributes) do
    { will_enter_nino: }
  end

  let(:crime_application) { instance_double(CrimeApplication, applicant: applicant_record) }
  let(:applicant_record) { Applicant.new }
  let(:will_enter_nino) { 'yes' }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq(YesNoAnswer.values)
    end
  end

  describe '#save' do
    context 'when `will_enter_nino` is not provided' do
      let(:will_enter_nino) { '' }

      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:will_enter_nino, :inclusion)).to be(true)
      end
    end

    context 'when `will_enter_nino` is not valid' do
      let(:will_enter_nino) { 'maybe' }

      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:will_enter_nino, :inclusion)).to be(true)
      end
    end

    context 'when form is valid' do
      it 'saves the record' do
        expect(applicant_record).to receive(:update).with(
          { 'will_enter_nino' => YesNoAnswer::YES }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
