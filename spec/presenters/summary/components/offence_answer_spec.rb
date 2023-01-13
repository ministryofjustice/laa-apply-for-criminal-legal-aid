require 'rails_helper'

describe Summary::Components::OffenceAnswer do
  subject { described_class.new(question, value) }

  let(:question) { 'Question?' }
  let(:value) { double(Charge) }

  describe '#to_partial_path' do
    it 'returns the correct partial path' do
      expect(subject.to_partial_path).to eq('steps/submission/shared/offence_answer')
    end
  end

  describe 'methods delegation' do
    it 'delegates `offence_name`' do
      expect(value).to receive(:offence_name)
      subject.offence_name
    end

    it 'delegates `offence_class`' do
      expect(value).to receive(:offence_class)
      subject.offence_class
    end

    it 'delegates `offence_dates`' do
      expect(value).to receive(:offence_dates)
      subject.offence_dates
    end

    it 'delegates `complete?`' do
      expect(value).to receive(:complete?)
      subject.complete?
    end
  end
end
