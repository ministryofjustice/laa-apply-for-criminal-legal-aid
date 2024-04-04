require 'rails_helper'

RSpec.describe Money do
  subject { described_class.new(value) }

  describe '==(other)' do
    let(:value) { 10_009 }

    it 'can be compared to an integer' do
      expect(subject).to eq(10_009)
      expect(subject).not_to eq(10_010)
    end

    it 'can be compared to a string' do
      expect(subject).to eq '100.090'
      expect(subject).not_to eq '100.10'
    end

    it 'can be compared to a float' do
      expect(subject).to eq 100.090
      expect(subject).not_to eq 100.091
    end
  end
end
