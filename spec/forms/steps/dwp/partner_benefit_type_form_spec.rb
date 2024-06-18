require 'rails_helper'

RSpec.describe Steps::DWP::PartnerBenefitTypeForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      record:,
      benefit_type:,
      last_jsa_appointment_date:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, partner: record) }
  let(:record) { Partner.new }

  let(:benefit_type) { BenefitType::UNIVERSAL_CREDIT.to_s }
  let(:last_jsa_appointment_date) { nil }

  describe '#save' do
    before do
      allow(record).to receive(:benefit_type).and_return(previous_benefit_type)
    end

    context 'when the benefit type has changed' do
      let(:previous_benefit_type) { BenefitType::GUARANTEE_PENSION.to_s }

      it 'saves `benefit_type` value and returns true' do
        expect(record).to receive(:update!).with({
                                                   'benefit_type' => BenefitType::UNIVERSAL_CREDIT,
                                                   'last_jsa_appointment_date' => nil,
                                                   'has_benefit_evidence' => nil,
                                                   'will_enter_nino' => nil,
                                                   'benefit_check_result' => nil,
                                                   'confirm_details' => nil,
                                                   'confirm_dwp_result' => nil,
                                                 }).and_return(true)
        expect(subject.save).to be(true)
      end
    end

    context 'when benefit type is the same as in the persisted record' do
      let(:previous_benefit_type) { BenefitType::UNIVERSAL_CREDIT.to_s }

      it 'does not save the record but returns true' do
        expect(record).not_to receive(:update!)
        expect(subject.save).to be(true)
      end
    end
  end
end
