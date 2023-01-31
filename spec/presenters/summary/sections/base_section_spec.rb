require 'rails_helper'

describe Summary::Sections::BaseSection do
  subject { described_class.new(crime_application, **arguments) }

  let(:crime_application) { CrimeApplication.new }
  let(:arguments) { {} }

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

  describe '#editable?' do
    context 'for an application `in_progress`' do
      it 'returns true' do
        expect(subject.editable?).to be(true)
      end
    end

    context 'for an application `in_progress` but editable is overridden' do
      let(:arguments) { { editable: false } }

      it 'returns false' do
        expect(subject.editable?).to be(false)
      end
    end

    context 'for an application other than `in_progress`' do
      let(:crime_application) do
        Adapters::BaseApplication.build(build_struct_application)
      end

      it 'returns false' do
        expect(subject.editable?).to be(false)
      end
    end
  end

  describe '#headless?' do
    context 'default value' do
      it 'returns false' do
        expect(subject.headless?).to be(false)
      end
    end

    context 'when configured to be headless' do
      let(:arguments) { { headless: true } }

      it 'returns true' do
        expect(subject.editable?).to be(true)
      end
    end
  end
end
