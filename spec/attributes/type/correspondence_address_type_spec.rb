require 'rails_helper'

RSpec.describe Type::CorrespondenceAddressType do
  subject { described_class.new }

  let(:coerced_value) { subject.cast(value) }

  describe 'registry' do
    it 'is registered with type `:correspondence_address_type`' do
      expect(
        ActiveModel::Type.lookup(:correspondence_address_type).is_a?(described_class)
      ).to eq(true)
    end

    it 'has an underlying type of `:string`' do
      expect(subject.type).to eq(:string)
    end
  end

  describe 'when value is `nil`' do
    let(:value) { nil }
    it { expect(coerced_value).to be_nil }
  end

  describe 'when value is a symbol' do
    let(:value) { :home_address }
    it { expect(coerced_value).to eq(CorrespondenceTypeAnswer::HOME_ADDRESS) }
  end

  describe 'when value is a string' do
    let(:value) { 'home_address' }
    it { expect(coerced_value).to eq(CorrespondenceTypeAnswer::HOME_ADDRESS) }
  end

  describe 'when value is already a value-object' do
    let(:value) { CorrespondenceTypeAnswer::HOME_ADDRESS }
    it { expect(coerced_value).to eq(CorrespondenceTypeAnswer::HOME_ADDRESS) }
  end
end
