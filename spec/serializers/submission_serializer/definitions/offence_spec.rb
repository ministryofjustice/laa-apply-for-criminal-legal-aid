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
        dates: %w[Date1 Date2],
      },
      {
        name: 'An unlisted offence',
        offence_class: nil,
        dates: %w[Date1],
      },
    ].as_json
  end

  before do
    allow(charge1).to receive(:offence_dates).and_return([{ date: 'Date1' }, { date: 'Date2' }])
    allow(charge2).to receive(:offence_dates).and_return([{ date: 'Date1' }])
  end

  describe '#generate' do
    it { expect(subject).to eq(json_output) }
  end
end
