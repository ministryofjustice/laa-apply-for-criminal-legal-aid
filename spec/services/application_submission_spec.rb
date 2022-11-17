require 'rails_helper'

RSpec.describe ApplicationSubmission do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      date_stamp:,
    )
  end

  before do
    allow(crime_application).to receive(:update!).and_return(true)
  end

  describe '#call' do
    let(:submitted_date) { DateTime.new(2022, 12, 31) }

    before do
      travel_to submitted_date
    end

    context 'when `date_stamp` attribute is `nil`' do
      let(:date_stamp) { nil }

      it 'marks the application as submitted, setting the `date_stamp` to the submission date' do
        expect(
          crime_application
        ).to receive(:update!).with(
          status: :submitted, submitted_at: submitted_date, date_stamp: submitted_date
        )

        expect(subject.call).to be(true)
      end
    end

    context 'when there is already a `date_stamp`' do
      let(:date_stamp) { DateTime.new(2022, 12, 15) }

      it 'marks the application as submitted, do not change the `date_stamp`' do
        expect(
          crime_application
        ).to receive(:update!).with(
          status: :submitted, submitted_at: submitted_date, date_stamp: date_stamp
        )

        expect(subject.call).to be(true)
      end
    end
  end
end
