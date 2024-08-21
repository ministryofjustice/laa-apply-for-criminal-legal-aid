require 'rails_helper'

RSpec.describe Steps::Partner::NinoForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      has_nino:,
      nino:,
      arc:,
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
  let(:arc) { nil }

  describe '#choices' do
    context 'when the arc feature flag is enabled' do
      before do
        allow(FeatureFlags).to receive(:arc) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: true)
        }
      end

      it 'returns the possible choices' do
        expect(
          subject.choices
        ).to eq([HasNinoType::YES, HasNinoType::NO, HasNinoType::ARC])
      end
    end

    context 'when the arc feature flag is not enabled' do
      before do
        allow(FeatureFlags).to receive(:arc) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: false)
        }
      end

      it 'returns the possible choices' do
        expect(
          subject.choices
        ).to eq([HasNinoType::YES, HasNinoType::NO])
      end
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

    context 'when `has_nino=yes` and `nino` is valid' do
      let(:has_nino) { 'yes' }
      let(:nino) { 'JA293483A' }

      it 'saves the record' do
        expect(partner).to receive(:update).with({
                                                   'has_nino' => HasNinoType::YES,
                                                   'nino' => 'JA293483A',
                                                   'arc' => nil,
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
                                                   'has_nino' => HasNinoType::NO,
                                                   'nino' => nil,
                                                   'arc' => nil,
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

    context 'when `has_nino` answer is no but they have an arc number' do
      let(:has_nino) { HasNinoType::ARC.to_s }
      let(:arc) { 'ABC12/345678/A' }

      context 'when `arc` is blank' do
        let(:arc) { '' }

        it 'has a validation error on the field' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:arc, :blank)).to be(true)
        end
      end

      context 'when `arc` is invalid' do
        let(:arc) { 'abcdefg' }

        it 'has a validation error on the field' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:arc, :invalid)).to be(true)
        end
      end

      context 'when `arc` is valid' do
        it 'passes validation' do
          expect(subject).to be_valid
          expect(subject.errors.of_kind?(:arc, :invalid)).to be(false)
        end
      end

      context 'when an `arc` was previously recorded' do
        it { is_expected.to be_valid }

        it 'cannot reset `arc` as it is relevant' do
          crime_application.partner.update(has_nino: HasNinoType::ARC.to_s)

          attributes = subject.send(:attributes_to_reset)
          expect(attributes['arc']).to eq(arc)
        end

        context 'when arc is the same as in the persisted record' do
          let(:previous_has_nino) { HasNinoType::ARC.to_s }
          let(:previous_arc) { 'ABC12/345678/A' }

          before do
            allow(partner).to receive_messages(has_nino: previous_has_nino, arc: previous_arc)
          end

          it 'does not save the record but returns true' do
            expect(partner).not_to receive(:update)
            expect(subject.save).to be(true)
          end
        end
      end
    end

    context 'when has nino is unchanged' do
      before do
        allow(partner).to receive_messages(has_nino: previous_has_nino, nino: previous_nino)
      end

      context 'when has nino is the same as in the persisted record' do
        let(:previous_has_nino) { HasNinoType::YES.to_s }
        let(:previous_nino) { 'AB123456C' }
        let(:has_nino) { HasNinoType::YES }
        let(:nino) { 'AB123456C' }

        it 'does not save the record but returns true' do
          expect(partner).not_to receive(:update)
          expect(subject.save).to be(true)
        end
      end
    end
  end
end
