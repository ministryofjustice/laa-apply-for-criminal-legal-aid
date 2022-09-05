require 'rails_helper'

RSpec.describe Steps::Case::HasCodefendantsForm do
  let(:arguments) { {
    crime_application: crime_application,
    has_codefendants: has_codefendants
  } }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:has_codefendants) { nil }

  subject { described_class.new(arguments) }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `has_codefendants` is not provided' do
      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:has_codefendants, :inclusion)).to eq(true)
      end
    end

    context 'when `has_codefendants` is not valid' do
      let(:has_codefendants) { 'maybe' }

      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:has_codefendants, :inclusion)).to eq(true)
      end
    end

    context 'when `has_codefendants` is valid' do
      context 'when answer is `yes`' do
        let(:has_codefendants) { 'yes' }

        it_behaves_like 'a has-one-association form',
                        association_name: :case,
                        expected_attributes: {
                          'has_codefendants' => YesNoAnswer::YES
                        }
      end

      context 'when answer is `no`' do
        let(:has_codefendants) { 'no' }

        it_behaves_like 'a has-one-association form',
                        association_name: :case,
                        expected_attributes: {
                          'has_codefendants' => YesNoAnswer::NO,
                          codefendants: [],
                        }
      end
    end
  end
end
