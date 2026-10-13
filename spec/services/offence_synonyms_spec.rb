require 'rails_helper'

describe OffenceSynonyms do
  describe '.lookup' do
    subject { described_class.lookup(offence_name) }

    context 'when no synonyms are found' do
      let(:offence_name) { 'Foobar offence' }

      it { is_expected.to eq([]) }
    end

    context 'when synonyms are found' do
      context 'for handling stolen goods for sale' do
        let(:offence_name) { 'Handle stolen goods, selling (£30,000 or less)' }

        it { is_expected.to contain_exactly('handling stolen goods, selling') }
      end

      context 'for buying stolen goods' do
        let(:offence_name) { 'Handling stolen goods, buying - Theft Act 1968 (£30,000 or less)' }

        it { is_expected.to contain_exactly('handle stolen goods, buying') }
      end

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
