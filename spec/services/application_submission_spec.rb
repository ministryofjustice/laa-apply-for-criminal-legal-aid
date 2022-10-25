require 'rails_helper'

RSpec.describe ApplicationSubmission do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
    )
  end

  before do
    allow(crime_application).to receive(:update!).and_return(true)
  end

  describe '#call' do
    let(:submitted_date) { Date.new(2022, 12, 31) }

    before do
      travel_to submitted_date
    end

    it 'marks the application as submitted' do
      expect(
        crime_application
      ).to receive(:update!).with(
        status: :submitted, submitted_at: submitted_date
      )

      expect(subject.call).to be(true)
    end
  end
end
