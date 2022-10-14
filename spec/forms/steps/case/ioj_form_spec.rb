require 'rails_helper'

RSpec.describe Steps::Case::IojForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
    record: ioj_record,
    types: types,
    loss_of_liberty_justification: loss_of_liberty_justification,
    reputation_justification: reputation_justification
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, case: kase) }
  let(:kase) { Case.new }
  let(:ioj_record) { Ioj.new }
  let(:types) { nil }
  let(:loss_of_liberty_justification) { nil }
  let(:reputation_justification) { nil }

  describe '#save' do
    context 'when `types` is empty' do
      let(:types) { [] }

      it 'has is a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:types, :invalid)).to be(true)
      end
    end

    context 'when `types` is valid' do
      let(:types) { [IojReasonType::REPUTATION.to_s, IojReasonType::OTHER.to_s] }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:types, :invalid)).to be(false)
      end
    end

    context 'when adding justification text' do
      let(:types) { ['loss_of_liberty'] }
      let(:loss_of_liberty_justification) { 'This is a loss of liberty justification' }

      it { is_expected.to be_valid }

      it 'does not reset justification area if still selected' do
        attributes = form.send(:attributes_to_reset)
        expect(attributes['loss_of_liberty_justification']).to eq('This is a loss of liberty justification')
      end

      context 'when text area needs resetting' do
        let(:types) { ['loss_of_liberty'] }
        let(:loss_of_liberty_justification) { 'This is a loss of liberty justification' }
        let(:other_justification) { 'This is a different justification' }

        it { is_expected.to be_valid }

        it 'can make justification area nil if ioj type deselected' do
          attributes = form.send(:attributes_to_reset)
          expect(attributes['other_justification']).to be_nil
        end
      end
    end

    context 'when validations pass' do
      let(:types) { [IojReasonType::REPUTATION.to_s] }
      let(:reputation_justification) { 'A justification' }
      let(:ioj_record_attributes) do
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
        expect(ioj_record).to receive(:update).with(
          ioj_record_attributes
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
