require 'rails_helper'

RSpec.describe Steps::Partner::InvolvementForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      involvement_in_case:
    }
  end

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      partner_detail:
    )
  end

  let(:partner_detail) { instance_double(PartnerDetail) }
  let(:involvement_in_case) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices.map(&:to_s)
      ).to match_array(%w[victim prosecution_witness codefendant none])
    end
  end

  describe '#save' do
    context 'when `involvement_in_case` is not provided' do
      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:involvement_in_case, :inclusion)).to be(true)
      end
    end

    context 'when `involvement_in_case` is invalid' do
      let(:involvement_in_case) { 'maybe' }

      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:involvement_in_case, :inclusion)).to be(true)
      end
    end

    context 'when `involvement_in_case` is valid' do
      let(:involvement_in_case) { 'victim' }

      it 'saves the record' do
        expect(partner_detail).to receive(:update).with(
          { 'involvement_in_case' => PartnerInvolvementType::VICTIM }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
