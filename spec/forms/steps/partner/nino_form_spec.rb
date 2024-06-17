require 'rails_helper'

RSpec.describe Steps::Partner::NinoForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      has_nino:,
      nino:,
    }
  end

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      partner:
    )
  end

  let(:partner) { Partner.new }
  let(:has_nino) { nil }
  let(:nino) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `has_nino` is not provided' do
      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:has_nino, :inclusion)).to be(true)
      end
    end

    context 'when `has_nino` is invalid' do
      let(:has_nino) { 'maybe' }

      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:has_nino, :inclusion)).to be(true)
      end
    end

    context 'when `nino` is invalid' do
      let(:has_nino) { 'yes' }
      let(:nino) { 'ABCDEFG' }

      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:nino, :invalid)).to be(true)
      end
    end

    context 'when `nino` is not provided' do
      let(:has_nino) { 'yes' }
      let(:nino) { '' }

      it 'has a validation error on the field' do
        expect(subject.save).to be(false)
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:nino, :blank)).to be(true)
      end
    end

    context 'when `has_nino` and `nino` is valid' do
      let(:has_nino) { 'yes' }
      let(:nino) { 'JA293483A' }

      it 'saves the record' do
        expect(partner).to receive(:update).with({
                                                   'has_nino' => YesNoAnswer::YES,
                                                   'nino' => 'JA293483A',
                                                   'benefit_type' => nil,
                                                   'last_jsa_appointment_date' => nil,
                                                   'benefit_check_result' => nil,
                                                   'will_enter_nino' => nil,
                                                   'has_benefit_evidence' => nil,
                                                   'confirm_details' => nil,
                                                   'confirm_dwp_result' => nil,
                                                 }).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when `has_nino` is valid' do
      let(:has_nino) { 'no' }
      let(:nino) { 'NotRequired' }

      it 'saves the record' do
        expect(partner).to receive(:update).with({
                                                   'has_nino' => YesNoAnswer::NO,
                                                   'nino' => nil,
                                                   'benefit_type' => nil,
                                                   'last_jsa_appointment_date' => nil,
                                                   'benefit_check_result' => nil,
                                                   'will_enter_nino' => nil,
                                                   'has_benefit_evidence' => nil,
                                                   'confirm_details' => nil,
                                                   'confirm_dwp_result' => nil,
                                                 }).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when has nino is unchanged' do
      before do
        allow(partner).to receive_messages(has_nino: previous_has_nino, nino: previous_nino)
      end

      context 'when has nino is the same as in the persisted record' do
        let(:previous_has_nino) { YesNoAnswer::YES.to_s }
        let(:previous_nino) { 'AB123456C' }
        let(:has_nino) { YesNoAnswer::YES }
        let(:nino) { 'AB123456C' }

        it 'does not save the record but returns true' do
          expect(partner).not_to receive(:update)
          expect(subject.save).to be(true)
        end
      end
    end
  end
end
