require 'rails_helper'

RSpec.describe ChargePresenter do
  subject { described_class.new(charge) }

  let(:charge) { Charge.new(offence_name:, offence_dates_attributes:) }

  let(:offence_name) { 'Common assault' }
  let(:offence_dates_attributes) { [] }

  let(:date1) { 1.year.ago.to_date }
  let(:date2) { 3.months.ago.to_date }

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
    context 'when there is at least a valid date' do
      let(:offence_dates_attributes) do
        [
          { date_from: date1, date_to: date2 },
          { date_from: date2, date_to: nil }
        ]
      end

      it 'retrieves the date pairs from the collection' do
        expect(subject.offence_dates).to match_array([[date1, date2], [date2, nil]])
      end
    end

    context 'when there are no valid dates' do
      let(:offence_dates_attributes) do
        [
          { date_from: nil, date_to: date2 },
          { date_from: nil, date_to: nil },
        ]
      end

      it 'returns an empty array' do
        expect(subject.offence_dates).to eq([])
      end
    end
  end
end
