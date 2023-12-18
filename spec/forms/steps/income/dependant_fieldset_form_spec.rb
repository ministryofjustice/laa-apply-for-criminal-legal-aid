require 'rails_helper'

RSpec.describe Steps::Income::DependantFieldsetForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      id: record_id,
      age: age
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:record_id) { '12345' }

  describe '#persisted?' do
    let(:age) { 5 }

    context 'when the record has an ID' do
      it { expect(subject.persisted?).to be(true) }
    end

    context 'when the record has no ID' do
      let(:record_id) { nil }

      it { expect(subject.persisted?).to be(false) }
    end
  end

  describe '#age' do
    before { subject.valid? }

    context 'when 0' do
      let(:age) { 0 }

      it { is_expected.to be_valid }
    end

    context 'when 17 or under' do
      let(:age) { 17 }

      it { is_expected.to be_valid }
    end

    context 'when 18 or over' do
      let(:age) { 18 }

      it { is_expected.not_to be_valid }
      it { expect(subject.errors.of_kind?(:age, :less_than)).to be(true) }
    end

    context 'when less than 0' do
      let(:age) { -1 }

      it { is_expected.not_to be_valid }
      it { expect(subject.errors.of_kind?(:age, :greater_than_or_equal_to)).to be(true) }
    end

    context 'when blank' do
      let(:age) { '' }

      it { is_expected.not_to be_valid }
      it { is_expected.to validate_presence_of(:age) }
      it { expect(subject.errors.of_kind?(:age, :blank)).to be(true) }
    end

    context 'when not a number' do
      let(:age) { ' twelve ' }

      it 'defaults to 0' do
        expect(subject).to be_valid
        expect(subject.age).to eq 0
      end
    end

    context 'when not a whole number' do
      let(:age) { 3.5 }

      it 'rounds down to a whole number' do
        expect(subject).to be_valid
        expect(subject.age).to eq 3
      end
    end
  end
end
