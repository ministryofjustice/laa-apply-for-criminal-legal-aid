require 'rails_helper'

RSpec.describe Steps::Partner::SameAddressForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      has_same_address_as_client:
    }
  end

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      partner_detail:,
      partner:,
    )
  end

  let(:partner_detail) { instance_double(PartnerDetail) }
  let(:partner) { instance_double(Partner) }
  let(:has_same_address_as_client) { nil }
  let(:home_address) { instance_double(Address) }

  before do
    allow(partner).to receive(:home_address).and_return(home_address)
  end

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `has_same_address_as_client` is not provided' do
      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:has_same_address_as_client, :inclusion)).to be(true)
      end
    end

    context 'when `has_same_address_as_client` is invalid' do
      let(:has_same_address_as_client) { 'maybe' }

      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:has_same_address_as_client, :inclusion)).to be(true)
      end
    end

    context 'when `has_same_address_as_client` is valid' do
      let(:has_same_address_as_client) { 'no' }

      it 'saves the record' do
        expect(partner_detail).to receive(:update!).with(
          { 'has_same_address_as_client' => YesNoAnswer::NO }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when `has_same_address_as_client` is `yes`' do
      let(:has_same_address_as_client) { 'yes' }

      before do
        allow(home_address).to receive(:destroy!).and_return(true)
        allow(partner).to receive(:home_address).and_return(home_address)
      end

      it 'deletes any existing home address' do
        expect(home_address).to receive(:destroy!)

        expect(partner_detail).to receive(:update!).with(
          { 'has_same_address_as_client' => YesNoAnswer::YES }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
