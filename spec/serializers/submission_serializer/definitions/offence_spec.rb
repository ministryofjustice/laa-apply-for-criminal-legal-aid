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

    [
      ['Handle stolen goods, selling (Over £30,000 up to £100,000)', true],
      ['Handling stolen goods, buying - Theft Act 1968 (Over £30,000 up to £100,000)', false],
      ['Handling stolen goods - Theft Act 1968 (Over £30,000 up to £100,000)', true],
      ['Handle stolen goods (Over £30,000 up to £100,000)', false],
    ].each do |name, slipstreamable|
      context "with #{name}" do
        let(:charges) { [Charge.new(offence_name: name)] }

        it 'preserves the saved wording and resolves the correct submission metadata' do
          expect(subject).to contain_exactly(
            include('name' => name, 'offence_class' => 'G', 'slipstreamable' => slipstreamable)
          )
        end
      end
    end
  end
end
