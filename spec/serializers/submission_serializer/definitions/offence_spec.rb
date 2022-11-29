require 'rails_helper'

RSpec.describe SubmissionSerializer::Definitions::Offence do
  subject { described_class }

  let(:offence) do
    instance_double(
      Charge,
      offence_name: 'Common Assault',
    )
  end

  let(:offence_date_one) do
    instance_double(
      OffenceDate,
      date: dates.first,
    )
  end

  let(:offence_date_two) do
    instance_double(
      OffenceDate,
      date: dates.last,
    )
  end

  let(:dates) { [DateTime.new(2022, 12, 1), DateTime.new(2022, 12, 3)] }

  let(:json_output) do
    {
      name: 'Common Assault',
      offence_class: nil,
      dates: dates,
    }.as_json
  end

  before do
    allow(offence).to receive(:offence_dates).and_return([offence_date_one, offence_date_two])
  end

  describe '#generate' do
    it { expect(subject.generate(offence)).to eq(json_output) }
  end
end
