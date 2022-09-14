require 'rails_helper'

RSpec.describe ChargePresenter do
  subject { described_class.new(charge) }

  let(:charge) {
    instance_double(
      Charge,
      id: '7a6f571e-f072-40a2-b0a1-aa79353141f8',
      offence_name: offence_name,
      offence_dates: offence_dates_double,
    )
  }

  let(:offence_dates_double) { double }
  let(:offence_name) { 'Robbery' }

  # TODO: just a mock
  describe '#offence_name' do
    context 'we have a name' do
      it { expect(subject.offence_name).to eq('Robbery') }
    end

    context 'we do not have a name' do
      let(:offence_name) { nil }
      it { expect(subject.offence_name).to eq('7a6f571e-f072-40a2-b0a1-aa79353141f8') }
    end
  end

  # TODO: just a mock
  describe '#offence_class' do
    it { expect(subject.offence_class).to eq('H') }
  end

  describe '#offence_dates' do
    it 'retrieves the `date` attribute from the collection' do
      expect(offence_dates_double).to receive(:pluck).and_return([nil, nil])
      expect(subject.offence_dates).to eq([])
    end
  end
end
