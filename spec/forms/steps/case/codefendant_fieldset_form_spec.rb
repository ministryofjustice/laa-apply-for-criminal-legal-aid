require 'rails_helper'

RSpec.describe Steps::Case::CodefendantFieldsetForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
    id: record_id,
    first_name: 'John',
    last_name: 'Doe',
    conflict_of_interest: conflict_of_interest,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:record_id) { '12345' }
  let(:conflict_of_interest) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#persisted?' do
    context 'when the record has an ID' do
      it { expect(subject.persisted?).to be(true) }
    end

    context 'when the record has no ID' do
      let(:record_id) { nil }

      it { expect(subject.persisted?).to be(false) }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }

    context 'when `conflict_of_interest` is not provided' do
      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:conflict_of_interest, :inclusion)).to be(true)
      end
    end

    context 'when `conflict_of_interest` is not valid' do
      let(:conflict_of_interest) { 'maybe' }

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:conflict_of_interest, :inclusion)).to be(true)
      end
    end

    context 'when `conflict_of_interest` is valid' do
      let(:conflict_of_interest) { 'yes' }

      it 'has no validation error' do
        expect(subject).to be_valid
      end
    end
  end
end
