require 'rails_helper'

RSpec.describe Charge, type: :model do
  subject { described_class.new(attributes) }

  let(:attributes) do
    { offence_name:, offence_dates_attributes: }
  end

  let(:offence_name) { nil }
  let(:offence_dates_attributes) { [] }

  let(:date1) { 1.year.ago.to_date }
  let(:date2) { 3.months.ago.to_date }

  describe '#offence' do
    context 'for a known offence' do
      let(:offence_name) { 'Common assault' }

      it { expect(subject.offence).not_to be_nil }
      it { expect(subject.offence.name).to eq(offence_name) }
    end

    context 'for an unknown offence' do
      let(:offence_name) { 'Foobar offence' }

      it { expect(subject.offence).to be_nil }
    end

    context 'for a blank offence' do
      let(:offence_name) { '' }

      it { expect(subject.offence).to be_nil }
    end
  end

  describe '#complete?' do
    context 'for an offence with name and dates' do
      let(:offence_name) { 'Foobar' }
      let(:offence_dates_attributes) { [{ date_from: date1 }, { date_from: date2 }] }

      it 'returns true' do
        expect(subject.complete?).to be(true)
      end
    end

    context 'for an offence with dates but no name' do
      let(:offence_name) { '' }
      let(:offence_dates_attributes) { [{ date_from: date1 }, { date_from: nil }] }

      it 'returns false' do
        expect(subject.complete?).to be(false)
      end
    end

    context 'for an offence with name but no dates' do
      let(:offence_name) { 'Foobar' }

      it 'returns false' do
        expect(subject.complete?).to be(false)
      end
    end

    context 'for an offence with name but some `date_from` missing' do
      let(:offence_name) { 'Foobar' }
      let(:offence_dates_attributes) { [{ date_from: date1 }, { date_from: nil, date_to: date2 }] }

      it 'returns false' do
        expect(subject.complete?).to be(false)
      end
    end

    context 'for an offence with no name and no valid dates' do
      let(:offence_name) { '' }
      let(:offence_dates_attributes) { [{ date_from: nil }] }

      it 'returns false' do
        expect(subject.complete?).to be(false)
      end
    end
  end
end
