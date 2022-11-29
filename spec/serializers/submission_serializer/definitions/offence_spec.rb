require 'rails_helper'

RSpec.describe SubmissionSerializer::Definitions::Offence do
  subject { described_class }

  let(:charge) do
    instance_double(
      Charge,
      offence_name: 'Common assault',
    )
  end

  let(:offence) do
    instance_double(
      Offence,
      name: 'Common assault',
      offence_class: 'H',
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
      name: 'Common assault',
      offence_class: 'H',
      dates: dates,
    }.as_json
  end

  before do
    allow(charge).to receive(:offence_dates).and_return([offence_date_one, offence_date_two])
    allow(charge).to receive(:offence).and_return(offence)
  end

  describe '#generate' do
    it { expect(subject.generate(charge)).to eq(json_output) }
  end
end
