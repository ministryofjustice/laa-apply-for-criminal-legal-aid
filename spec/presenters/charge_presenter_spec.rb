require 'rails_helper'

RSpec.describe ChargePresenter do
  subject { described_class.new(charge) }

  let(:charge) { Charge.new(offence_name: offence_name) }
  let(:offence_name) { 'Common assault' }

  describe 'offence attributes delegation' do
    context 'when there is an offence instance' do
      let(:offence) { charge.offence }

      context '#offence_class' do
        it 'delegates to the presented offence' do
          expect(offence).to receive(:offence_class).and_call_original
          expect(subject.offence_class).to eq('Class H')
        end
      end

      context '#offence_type' do
        it 'delegates to the presented offence' do
          expect(offence).to receive(:offence_type).and_call_original
          expect(subject.offence_type).to eq('CS Summary Non-Motoring')
        end
      end
    end

    context 'when offence instance is `nil`' do
      let(:offence_name) { 'Foobar offence' }

      context '#offence_class' do
        it { expect(subject.offence_class).to be_nil }
      end

      context '#offence_type' do
        it { expect(subject.offence_type).to be_nil }
      end
    end
  end

  describe '#offence_dates' do
    let(:offence_dates_double) { double }

    before do
      allow(
        charge
      ).to receive(:offence_dates).and_return(offence_dates_double)
    end

    it 'retrieves the `date` attribute from the collection' do
      expect(offence_dates_double).to receive(:pluck).and_return([nil, nil])
      expect(subject.offence_dates).to eq([])
    end
  end
end
