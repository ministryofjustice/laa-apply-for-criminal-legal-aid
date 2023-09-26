require 'rails_helper'

RSpec.describe Steps::Client::BenefitTypeForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: applicant_record,
      benefit_type: benefit_type,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, applicant: applicant_record) }
  let(:applicant_record) { Applicant.new }

  let(:benefit_type) { BenefitType::UNIVERSAL_CREDIT.to_s }

  describe 'validations' do
    context 'when `benefit_type` is blank' do
      let(:benefit_type) { '' }

      it 'has is a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:benefit_type, :inclusion)).to be(true)
      end
    end

    context 'when `benefit_type` is invalid' do
      let(:benefit_type) { 'invalid_type' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:benefit_type, :inclusion)).to be(true)
      end
    end

    context 'when `benefit_type` is valid' do
      it { is_expected.to be_valid }
    end
  end

  describe '#save' do
    before do
      allow(applicant_record).to receive(:benefit_type).and_return(previous_benefit_type)
    end

    context 'when the benefit type has changed' do
      let(:previous_benefit_type) { BenefitType::GUARANTEE_PENSION.to_s }

      it_behaves_like 'a has-one-association form',
                      association_name: :applicant,
                      expected_attributes: {
                        'benefit_type' => BenefitType::UNIVERSAL_CREDIT,
                      }
    end

    context 'when benefit type is the same as in the persisted record' do
      let(:previous_benefit_type) { BenefitType::UNIVERSAL_CREDIT.to_s }

      it 'does not save the record but returns true' do
        expect(applicant_record).not_to receive(:update)
        expect(subject.save).to be(true)
      end
    end
  end
end
