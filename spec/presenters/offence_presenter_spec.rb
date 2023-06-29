require 'rails_helper'

RSpec.describe OffencePresenter do
  let(:offence) do
    instance_double(
      Offence,
      name:,
      offence_class:,
    )
  end

  let(:name) { 'Foobar offence' }
  let(:offence_class) { 'H' }

  describe '#offence_class' do
    subject { described_class.new(offence).offence_class }

    it { is_expected.to eq('Class H') }
  end

  describe '#synonyms' do
    subject { described_class.new(offence).synonyms }

    before do
      allow(OffenceSynonyms).to receive(:lookup).with(name).and_return(synonyms)
    end

    context 'when no synonyms are found' do
      let(:synonyms) { [] }

      it { is_expected.to be_nil }
    end

    context 'when synonyms are found' do
      let(:synonyms) { %w[one another] }

      it { is_expected.to eq('one|another') }
    end
  end
end
