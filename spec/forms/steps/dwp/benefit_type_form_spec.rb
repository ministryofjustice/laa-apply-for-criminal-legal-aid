require 'rails_helper'

RSpec.describe Steps::DWP::BenefitTypeForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      record:,
      benefit_type:,
      last_jsa_appointment_date:
    }
  end

  let(:crime_application) do
    CrimeApplication.new(applicant: record, partner: partner_record)
  end

  let(:record) { Applicant.new }
  let(:partner_record) { Partner.new }

  let(:benefit_type) { BenefitType::UNIVERSAL_CREDIT.to_s }
  let(:last_jsa_appointment_date) { nil }

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
      let(:benefit_type) { BenefitType::UNIVERSAL_CREDIT.to_s }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:benefit_type, :invalid)).to be(false)
      end

      it 'saves `benefit_type` value and returns true' do
        expect(record).to receive(:update!).with({
                                                   'benefit_type' => BenefitType::UNIVERSAL_CREDIT,
                                                   'last_jsa_appointment_date' => nil,
                                                   'has_benefit_evidence' => nil,
                                                   'will_enter_nino' => nil,
                                                   'benefit_check_result' => nil,
                                                   'confirm_details' => nil,
                                                   'confirm_dwp_result' => nil
                                                 }).and_return(true)
        expect(partner_record).to receive(:update!).with({
                                                           'last_jsa_appointment_date' => nil,
                                                           'has_benefit_evidence' => nil,
                                                           'will_enter_nino' => nil,
                                                           'benefit_check_result' => nil,
                                                           'confirm_details' => nil,
                                                           'confirm_dwp_result' => nil
                                                         }).and_return(true)
        expect(subject.save).to be(true)
      end

      context 'when `benefit_type` answer is not jsa' do
        context 'when a `last_jsa_appointment_date` was previously recorded' do
          let(:last_jsa_appointment_date) { 1.month.ago.to_date }

          it { is_expected.to be_valid }

          it 'can make last_jsa_appointment_date field nil if no longer required' do
            attributes = form.send(:attributes_to_reset)
            expect(attributes['last_jsa_appointment_date']).to be_nil
          end
        end
      end

      context 'when `benefit_type` answer is jsa' do
        context 'when a `last_jsa_appointment_date` was previously recorded' do
          let(:benefit_type) { BenefitType::JSA.to_s }
          let(:last_jsa_appointment_date) { 1.month.ago.to_date }

          it 'is valid' do
            expect(form).to be_valid
            expect(
              form.errors.of_kind?(
                :last_jsa_appointment_date,
                :present
              )
            ).to be(false)
          end

          it 'cannot reset `last_jsa_appointment_date` as it is relevant' do
            record.update(benefit_type: BenefitType::JSA.to_s)

            attributes = form.send(:attributes_to_reset)
            expect(attributes['last_jsa_appointment_date']).to eq(last_jsa_appointment_date)
          end
        end

        context 'when a `last_jsa_appointment_date` was not previously recorded' do
          let(:benefit_type) { BenefitType::JSA.to_s }
          let(:last_jsa_appointment_date) { 1.month.ago.to_date }

          it 'is also valid' do
            expect(form).to be_valid
            expect(
              form.errors.of_kind?(
                :last_jsa_appointment_date,
                :present
              )
            ).to be(false)
          end
        end
      end
    end
  end

  describe '#save' do
    before do
      allow(record).to receive(:benefit_type).and_return(previous_benefit_type)
    end

    context 'when the benefit type has changed' do
      let(:previous_benefit_type) { BenefitType::GUARANTEE_PENSION.to_s }

      it 'saves `benefit_type` value and returns true' do
        expect(record).to receive(:update).with({
                                                  'benefit_type' => BenefitType::UNIVERSAL_CREDIT,
                                                  'last_jsa_appointment_date' => nil,
                                                  'has_benefit_evidence' => nil,
                                                  'will_enter_nino' => nil,
                                                  'benefit_check_result' => nil,
                                                  'confirm_details' => nil,
                                                  'confirm_dwp_result' => nil
                                                }).and_return(true)
        expect(partner_record).to receive(:update).with({
                                                          'last_jsa_appointment_date' => nil,
                                                  'has_benefit_evidence' => nil,
                                                  'will_enter_nino' => nil,
                                                  'benefit_check_result' => nil,
                                                  'confirm_details' => nil,
                                                  'confirm_dwp_result' => nil
                                                        }).and_return(true)
        expect(subject.save).to be(true)
      end
    end

    context 'when benefit type is the same as in the persisted record' do
      let(:previous_benefit_type) { BenefitType::UNIVERSAL_CREDIT.to_s }

      it 'does not save the record but returns true' do
        expect(record).not_to receive(:update)
        expect(subject.save).to be(true)
      end
    end
  end
end
