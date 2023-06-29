require 'rails_helper'

describe OffenceSynonyms do
  describe '.lookup' do
    subject { described_class.lookup(offence_name) }

    context 'when no synonyms are found' do
      let(:offence_name) { 'Foobar offence' }

      it { is_expected.to eq([]) }
    end

    context 'when synonyms are found' do
      context 'one synonym' do
        let(:offence_name) { 'Section 18 - attempt wounding with intent' }

        it { is_expected.to contain_exactly('s18') }
      end

      context 'multiple synonyms' do
        let(:offence_name) { 'Section 18 - grievous bodily harm with intent' }

        it { is_expected.to contain_exactly('gbh', 's18') }
      end
    end
  end
end
