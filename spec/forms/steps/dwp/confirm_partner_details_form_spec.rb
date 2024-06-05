require 'rails_helper'

RSpec.describe Steps::DWP::ConfirmPartnerDetailsForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      confirm_details:,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, partner:) }
  let(:partner) { instance_double(Partner, confirm_details:) }
  let(:confirm_details) { nil }

  describe '#save' do
    context 'when `confirm_details` is `yes`' do
      let(:confirm_details) { 'yes' }

      it 'saves `confirm_details` value and returns true' do
        expect(partner).to receive(:update).with({ 'confirm_details' => YesNoAnswer::YES }).and_return(true)
        expect(subject.save).to be(true)
      end
    end
  end
end
