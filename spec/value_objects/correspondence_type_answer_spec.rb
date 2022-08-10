require 'rails_helper'

RSpec.describe CorrespondenceTypeAnswer do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w(home_address providers_office_address other_address)
      )
    end
  end

  describe '#home_address?' do
    context 'when value is `home_address`' do
      let(:value) { :home_address }
      it { expect(subject.home_address?).to eq(true) }
    end

    context 'when value is not `home_address`' do
      let(:value) { :providers_office_address }
      it { expect(subject.home_address?).to eq(false) }
    end
  end
  describe '#providers_office_address?' do
    context 'when value is `providers_office_address`' do
      let(:value) { :providers_office_address }
      it { expect(subject.providers_office_address?).to eq(true) }
    end

    context 'when value is not `providers_office_address`' do
      let(:value) { :home_address }
      it { expect(subject.providers_office_address?).to eq(false) }
    end
  end

  describe '#other_address?' do
    context 'when value is `providers_office_address`' do
      let(:value) { :other_address }
      it { expect(subject.other_address?).to eq(true) }
    end

    context 'when value is not `other_address`' do
      let(:value) { :providers_office_address }
      it { expect(subject.other_address?).to eq(false) }
    end
  end

end
