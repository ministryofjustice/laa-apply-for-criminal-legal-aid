require 'rails_helper'

RSpec.describe Steps::Evidence::UploadForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) { { crime_application: } }

  # Expect the StocksAndGilts and OwnShares rules to be triggered
  let(:crime_application) do
    CrimeApplication.create!(
      applicant: Applicant.new(date_of_birth: '2000-01-01'),
      partner: Partner.new(date_of_birth: '2000-01-01'),
      partner_detail: PartnerDetail.new(involvement_in_case: 'none'),
      investments: [
        Investment.new(investment_type: 'share', ownership_type: :applicant),
        Investment.new(investment_type: 'stock', ownership_type: :partner),
      ]
    )
  end

  before do
    allow(MeansStatus).to receive(:include_partner?).and_return(true)
  end

  describe '#prompt' do
    subject { form.prompt }

    it 'generates sentences for the client' do
      sentences = subject.result_for(group: :capital, persona: :client).last.dig(:run, :client, :prompt)

      expect(sentences).to eq ['share certificate or latest dividend counterfoil for each company they hold shares in']
    end

    it 'generates sentences for the partner' do
      sentences = subject.result_for(group: :capital, persona: :partner).last.dig(:run, :partner, :prompt)

      expect(sentences).to eq ['certificate or statement for each stock, gilt or government bond']
    end
  end
end
