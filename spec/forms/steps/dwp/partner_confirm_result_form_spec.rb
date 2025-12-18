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
