require 'rails_helper'

RSpec.describe ChargePresenter do
  subject { described_class.new(charge) }

  let(:charge) { Charge.new(offence_name:) }
  let(:offence_name) { 'Common assault' }

  describe 'offence attributes delegation' do
    context 'when there is an offence instance' do
      let(:offence) { charge.offence }

      describe '#offence_class' do
        it 'delegates to the presented offence' do
          expect(OffencePresenter).to receive(:present).with(offence)
          subject.offence_class
        end
      end

      describe '#offence_type' do
        it 'delegates to the presented offence' do
          expect(OffencePresenter).to receive(:present).with(offence)
          subject.offence_type
        end
      end
    end

    context 'when offence instance is `nil`' do
      let(:offence_name) { 'Foobar' }

      describe '#offence_class' do
        it { expect(subject.offence_class).to be_nil }
      end

      describe '#offence_type' do
        it { expect(subject.offence_type).to be_nil }
      end
    end
  end

  describe '#offence_dates' do
    before do
      allow(
        charge
      ).to receive(:offence_dates).and_return(offence_dates_double)
    end

    context 'when there is at least a valid date' do
      let(:offence_dates_double) do
        [
          { date_from: 'date_from_1', date_to: 'date_to_1' },
          { date_from: 'date_from_2', date_to: nil }
        ]
      end

      it 'retrieves the dates from the collection' do
        expect(subject.offence_dates).to eq([%w[date_from_1 date_to_1], ['date_from_2', nil]])
      end
    end

    context 'when there are no valid dates' do
      let(:offence_dates_double) do
        [
          { date_from: nil, date_to: 'date_to_1' },
          { date_from: nil, date_to: nil },
        ]
      end

      it 'returns an empty array' do
        expect(subject.offence_dates).to eq([])
      end
    end
  end
end
