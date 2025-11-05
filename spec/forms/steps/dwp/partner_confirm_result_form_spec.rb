require 'rails_helper'

RSpec.describe Steps::DWP::PartnerConfirmResultForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, partner:) }
  let(:partner) { instance_double(Partner) }

  context 'when dwp undetermined feature is enabled' do
    before do
      allow(FeatureFlags).to receive(:dwp_undetermined) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: true)
      }
    end

    describe '#save' do
      context 'when form is saved' do
        it 'resets necessary partner attributes' do
          expect(partner).to receive(:update).with({
                                                     'benefit_type' => BenefitType::NONE,
                                                     'has_benefit_evidence' => nil,
                                                     'confirm_details' => nil
                                                   }).and_return(true)
          expect(subject.save).to be(true)
        end
      end
    end
  end

  context 'when dwp undetermined feature is disabled' do
    let(:arguments) do
      {
        crime_application:,
        confirm_dwp_result:,
      }
    end

    let(:partner) { instance_double(Partner, confirm_dwp_result:) }
    let(:confirm_dwp_result) { nil }

    describe '#save' do
      context 'when `confirm_dwp_result` is `yes`' do
        let(:confirm_dwp_result) { 'yes' }

        it 'saves `confirm_dwp_result` value and returns true' do
          expect(partner).to receive(:update)
            .with({ 'confirm_dwp_result' => YesNoAnswer::YES }).and_return(true)
          expect(partner).to receive(:update).with({
                                                     'benefit_type' => BenefitType::NONE,
                                                     'has_benefit_evidence' => nil,
                                                     'confirm_details' => nil
                                                   }).and_return(true)
          expect(subject.save).to be(true)
        end
      end
    end
  end
end
