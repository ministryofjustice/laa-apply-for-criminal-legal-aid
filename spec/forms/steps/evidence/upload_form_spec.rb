require 'rails_helper'

RSpec.describe Steps::Evidence::UploadForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:
    }
  end

  let(:crime_application) do
    CrimeApplication.create!(
      investments: [
        Investment.new(investment_type: 'share', ownership_type: :applicant),
        Investment.new(investment_type: 'stock', ownership_type: :partner),
      ]
    )
  end

  describe '#prompt' do
    subject { form.prompt }

    # Expect
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
