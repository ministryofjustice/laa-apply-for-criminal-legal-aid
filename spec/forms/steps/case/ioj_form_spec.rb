require 'rails_helper'

RSpec.describe Steps::Case::IojForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
    types:,
    other_justification:,
    reputation_justification:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, case: kase) }
  let(:kase) { instance_double(Case, ioj:) }
  let(:ioj) { instance_double(Ioj) }
  let(:types) { nil }
  let(:other_justification) { nil }
  let(:reputation_justification) { nil }

  describe '#save' do
    context 'when `types` is invalid' do
      context 'when `types` is empty' do
        let(:types) { [] }

        it 'has is a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:types, :invalid)).to be(true)
        end
      end

      context 'when `types` selected is not a valid option' do
        let(:types) { ['foo'] }

        it 'has is a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:types, :invalid)).to be(true)
        end
      end

      context 'when `types` selected has a valid and an invalid option' do
        let(:types) { %w[foo other] }

        it 'has is a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:types, :invalid)).to be(true)
        end
      end
    end

    context 'when `types` is valid' do
      let(:types) { [IojReasonType::REPUTATION.to_s] }

      context 'when text area needs resetting' do
        let(:reputation_justification) { 'This is a justification' }
        let(:other_justification) { 'This is a different justification' }

        it { is_expected.to be_valid }

        it 'can make justification area nil if ioj type deselected' do
          expect(ioj).to receive(:update).with(
            hash_including({ 'types' => ['reputation'], 'reputation_justification' => 'This is a justification',
'other_justification' => nil })
          ).and_return(true)

          subject.save
        end
      end

      context 'and justification text is not added' do
        let(:reputation_justification) { nil }

        it { is_expected.not_to be_valid }
      end
    end

    context 'when validations pass' do
      let(:types) { [IojReasonType::REPUTATION.to_s] }
      let(:reputation_justification) { 'A justification' }
      let(:ioj_attributes) do
        {
          'types' => ['reputation'],
          'expert_examination_justification' => nil,
          'interest_of_another_justification' => nil,
          'loss_of_liberty_justification' => nil,
          'loss_of_livelyhood_justification' => nil,
          'other_justification' => nil,
          'question_of_law_justification' => nil,
          'reputation_justification' => 'A justification',
          'suspended_sentence_justification' => nil,
          'understanding_justification' => nil,
          'witness_tracing_justification' => nil
        }
      end

      it 'updates the record' do
        expect(ioj).to receive(:update).with(
          ioj_attributes
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
