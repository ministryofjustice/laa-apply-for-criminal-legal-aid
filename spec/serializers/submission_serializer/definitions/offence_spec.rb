require 'rails_helper'

RSpec.describe SubmissionSerializer::Definitions::Offence do
  subject { described_class.generate(charges) }

  let(:charges) { [charge1, charge2] }

  let(:charge1) { Charge.new(offence_name: 'Common assault') }
  let(:charge2) { Charge.new(offence_name: 'An unlisted offence') }

  let(:json_output) do
    [
      {
        name: 'Common assault',
        offence_class: 'H',
        slipstreamable: true,
        dates: [
          { date_from: 'date_from_1', date_to: 'date_to_1' }, { date_from: 'date_from_2', date_to: nil }
        ],
      },
      {
        name: 'An unlisted offence',
        offence_class: nil,
        slipstreamable: false,
        dates: [
          { date_from: 'date_from_1', date_to: nil }
        ]
      },
    ].as_json
  end

  before do
    allow(charge1).to receive(:offence_dates).and_return(
      [
        { date_from: 'date_from_1', date_to: 'date_to_1' },
        { date_from: 'date_from_2', date_to: nil }
      ]
    )
    allow(charge2).to receive(:offence_dates).and_return(
      [
        { date_from: 'date_from_1', date_to: nil }
      ]
    )
  end

  describe '#generate' do
    it { expect(subject).to eq(json_output) }
  end
end
