require 'rails_helper'

RSpec.describe Steps::Partner::InvolvementForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      involved_in_case:
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
  let(:involved_in_case) { nil }
  let(:home_address) { instance_double(Address) }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices.map(&:to_s)
      ).to match_array(%w[yes no])
    end
  end

  describe '#save' do
    context 'when `involved_in_case` is not provided' do
      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:involved_in_case, :inclusion)).to be(true)
      end
    end

    context 'when `involved_in_case` is invalid' do
      let(:involved_in_case) { 'maybe' }

      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:involved_in_case, :inclusion)).to be(true)
      end
    end

    context 'when `involved_in_case` is `yes`' do
      let(:involved_in_case) { 'yes' }

      before do
        allow(home_address).to receive(:destroy!).and_return(true)
        allow(partner).to receive(:home_address).and_return(home_address)
      end

      it 'saves the record and deletes existing home address' do
        expect(home_address).to receive(:destroy!)

        expect(partner_detail).to receive(:update!).with(
          { 'involved_in_case' => YesNoAnswer::YES }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when `involved_in_case` is `no`' do
      let(:involved_in_case) { 'no' }

      before do
        allow(home_address).to receive(:destroy!).and_return(true)
        allow(partner).to receive(:home_address).and_return(home_address)
      end

      it 'saves the record and does not delete home address' do
        expect(home_address).not_to receive(:destroy!)

        expect(partner_detail).to receive(:update!).with(
          { 'involved_in_case' => YesNoAnswer::NO }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
