require 'rails_helper'

RSpec.describe PostSubmissionApplicationPurger do
  let(:crime_application) { instance_double(CrimeApplication, partner: nil) }

  before do
    allow(crime_application).to receive(:destroy!)
  end

  describe '.call' do
    context 'when it has orphan partner assets' do
      let(:documents) { [] }
      let(:partner_savings) { double(:partner_savings) }

      before do
        allow(crime_application).to receive(:partner).and_return(Partner.new)
        allow(MeansStatus).to receive(:include_partner?).and_return(false)
        allow(Saving).to receive(:where).with(
          crime_application: crime_application,
          ownership_type: 'partner'
        ).and_return(partner_savings)
      end

      it 'deletes the orhpan assets' do
        expect(partner_savings).to receive(:delete_all)
        expect(crime_application).to receive(:destroy!)
        described_class.call(crime_application)
      end
    end
  end
end
