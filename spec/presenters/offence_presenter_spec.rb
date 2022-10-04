require 'rails_helper'

RSpec.describe OffencePresenter do
  let(:offence) do
    instance_double(
      Offence,
      offence_class:
    )
  end

  describe '#offence_class' do
    subject { described_class.new(offence).offence_class }

    context 'for an offence with 1 class' do
      let(:offence_class) { 'H' }

      it { is_expected.to eq('Class H') }
    end

    context 'for an offence with 2 classes' do
      let(:offence_class) { 'C/B' }

      it { is_expected.to eq('Class C or B') }
    end

    context 'for an offence with 3 classes' do
      let(:offence_class) { 'F/G/K' }

      it { is_expected.to eq('Class F, G or K') }
    end
  end
end
