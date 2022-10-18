require 'rails_helper'

describe Summary::Components::BaseAnswer do
  subject { described_class.new(question, value, default:, change_path:) }

  let(:question) { 'Question?' }
  let(:value) { 'Answer!' }
  let(:change_path) { nil }
  let(:default) { nil }

  describe 'validates the options' do
    subject { described_class.new(question, value, test: true) }

    it 'raises an exception' do
      expect { subject.show? }.to raise_error(ArgumentError)
    end
  end

  describe '#show?' do
    it 'returns true' do
      expect(subject.show?).to be(true)
    end

    context 'when no value is given' do
      let(:value) { nil }

      it 'returns false' do
        expect(subject.show?).to be(false)
      end
    end

    context 'when `show` is enabled via arguments' do
      subject { described_class.new(question, nil, show: true) }

      it 'returns true regardless of `value` being nil' do
        expect(subject.show?).to be(true)
      end
    end
  end

  describe '#value?' do
    it 'returns true' do
      expect(subject.value?).to be(true)
    end

    context 'when no value is given' do
      let(:value) { nil }

      it 'returns false' do
        expect(subject.value?).to be(false)
      end
    end
  end

  describe 'can be given a default value' do
    context 'when value is nil' do
      let(:value) { nil }
      let(:default) { 'no' }

      it 'returns the default value' do
        expect(subject.value).to eq('no')
      end
    end

    context 'when value is not nil' do
      let(:value) { 'yes' }
      let(:default) { 'no' }

      it 'returns the original value' do
        expect(subject.value).to eq('yes')
      end
    end
  end

  describe 'can be given i18n options' do
    context 'when value is nil' do
      subject { described_class.new(question, value, i18n_opts: { name: 'John' }) }

      it 'returns the options' do
        expect(subject.i18n_opts).to eq({ name: 'John' })
      end
    end
  end

  describe '#change_link?' do
    it 'returns false' do
      expect(subject.change_link?).to be(false)
    end

    context 'when change_path is given' do
      let(:change_path) { '/change' }

      it 'returns true' do
        expect(subject.change_link?).to be(true)
      end
    end
  end
end
