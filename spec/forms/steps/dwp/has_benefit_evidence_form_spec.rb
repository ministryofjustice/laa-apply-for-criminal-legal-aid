require 'rails_helper'

RSpec.describe Steps::DWP::HasBenefitEvidenceForm do
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
    { has_benefit_evidence: }
  end

  let(:crime_application) { instance_double(CrimeApplication, applicant: applicant_record) }
  let(:applicant_record) { Applicant.new }
  let(:has_benefit_evidence) { 'yes' }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq(YesNoAnswer.values)
    end
  end

  describe '#save' do
    context 'when `has_benefit_evidence` is not provided' do
      let(:has_benefit_evidence) { '' }

      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:has_benefit_evidence, :inclusion)).to be(true)
      end
    end

    context 'when `has_benefit_evidence` is not valid' do
      let(:has_benefit_evidence) { 'maybe' }

      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:has_benefit_evidence, :inclusion)).to be(true)
      end
    end

    context 'when form is valid' do
      it 'saves the record' do
        expect(applicant_record).to receive(:update).with(
          { 'has_benefit_evidence' => YesNoAnswer::YES }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
