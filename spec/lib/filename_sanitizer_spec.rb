require 'rails_helper'

RSpec.describe FilenameSanitizer do
  describe '.call' do
    subject(:sanitized) { described_class.call(filename) }

    context 'with a plain, valid filename' do
      let(:filename) { 'client-bank-statement.pdf' }

      it { is_expected.to eq('client-bank-statement.pdf') }
    end

    context 'with a colon (macOS stores a Finder slash as a colon)' do
      let(:filename) { 'invoice 03:04.pdf' }

      it { is_expected.to eq('invoice 03-04.pdf') }
    end

    context 'with path separators' do
      let(:filename) { 'client/statements\\jan.pdf' }

      it { is_expected.to eq('client-statements-jan.pdf') }
    end

    context 'with assorted unsupported characters' do
      let(:filename) { 'bank*state?ment<v2>|"final".pdf' }

      it { is_expected.to eq('bank-state-ment-v2-final-.pdf') }
    end

    context 'with runs of separators and surrounding whitespace' do
      let(:filename) { '  my :: important   file .pdf  ' }

      it { is_expected.to eq('my - important file .pdf') }
    end

    context 'with leading dots and hyphens' do
      let(:filename) { '.-:hidden.pdf' }

      it { is_expected.to eq('hidden.pdf') }
    end

    context 'with accented (unicode) letters' do
      let(:filename) { 'café résumé.pdf' }

      it 'preserves the letters' do
        expect(sanitized).to eq('café résumé.pdf')
      end
    end

    context 'when the name has no supported characters' do
      let(:filename) { '***' }

      it { is_expected.to eq('file') }
    end

    context 'when blank' do
      let(:filename) { '' }

      it { is_expected.to eq('file') }
    end

    context 'when nil' do
      let(:filename) { nil }

      it { is_expected.to eq('file') }
    end
  end
end
