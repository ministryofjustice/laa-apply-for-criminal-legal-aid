require 'rails_helper'

describe Summary::Sections::BaseSection do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication) }

  describe '#to_partial_path' do
    it 'returns the partial path' do
      expect(subject.to_partial_path).to eq('steps/submission/shared/section')
    end
  end

  describe '#show?' do
    context 'for an empty answers collection' do
      before do
        expect(subject).to receive(:answers).and_return([])
      end

      it 'returns false' do
        expect(subject.show?).to be(false)
      end
    end

    context 'for a not empty answers collection' do
      before do
        expect(subject).to receive(:answers).and_return(['blah'])
      end

      it 'returns true' do
        expect(subject.show?).to be(true)
      end
    end
  end
end
