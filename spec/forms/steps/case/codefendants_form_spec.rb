require 'rails_helper'

RSpec.describe Steps::Case::CodefendantsForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      codefendants_attributes:,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, case: case_record) }
  let(:case_record) { Case.new }

  let(:codefendants_attributes) do
    {
      '0' => { 'first_name' => 'John', 'last_name' => 'Doe', 'conflict_of_interest' => 'no' },
      '1' => { 'first_name' => 'Jane', 'last_name' => 'Doe', 'conflict_of_interest' => 'yes' },
    }
  end

  describe '#codefendants' do
    context 'there are no codefendants' do
      let(:codefendants_attributes) { {} }

      it 'returns an empty collection' do
        expect(subject.codefendants).to eq([])
      end
    end

    context 'there are existing codefendants' do
      it 'builds a collection of `CodefendantFieldsetForm` instances' do
        expect(
          subject.codefendants
        ).to contain_exactly(Steps::Case::CodefendantFieldsetForm, Steps::Case::CodefendantFieldsetForm)

        expect(subject.codefendants[0].first_name).to eq('John')
        expect(subject.codefendants[0].last_name).to eq('Doe')
        expect(subject.codefendants[0].conflict_of_interest).to eq(YesNoAnswer::NO)

        expect(subject.codefendants[1].first_name).to eq('Jane')
        expect(subject.codefendants[1].last_name).to eq('Doe')
        expect(subject.codefendants[1].conflict_of_interest).to eq(YesNoAnswer::YES)
      end
    end
  end

  describe '#any_marked_for_destruction?' do
    # NOTE: this scenario requires real DB records to exercise nested attributes
    context 'there are records marked for destruction' do
      let(:crime_application) { CrimeApplication.create!(case: case_record) }
      let(:case_record) { Case.new(codefendants: [codefendant]) }
      let(:codefendant) { Codefendant.new(first_name: 'John', last_name: 'Doe') }

      let(:codefendants_attributes) do
        {
          '0' => codefendant.slice(:first_name, :last_name, :id).merge(_destroy: '1'),
          '1' => { first_name: 'Jane', last_name: 'Doe' },
        }
      end

      it 'returns true' do
        expect(subject.any_marked_for_destruction?).to be(true)

        expect(subject.codefendants[0]._destroy).to be(true)
        expect(subject.codefendants[1]._destroy).to be(false)
      end
    end

    context 'there are no records to be destroyed' do
      it { expect(subject.any_marked_for_destruction?).to be(false) }
    end
  end

  describe '#show_destroy?' do
    context 'there is only 1 codefendant' do
      let(:codefendants_attributes) { { '0' => { 'first_name' => 'John', 'last_name' => 'Doe' } } }

      it { expect(subject.show_destroy?).to be(false) }
    end

    context 'there are more than 1 codefendant' do
      it { expect(subject.show_destroy?).to be(true) }
    end
  end

  describe '#save' do
    context 'when there are errors in any of the codefendants' do
      let(:codefendants_attributes) do
        {
          '0' => { 'first_name' => 'John', 'last_name' => '', 'conflict_of_interest' => '' },
          '1' => { 'first_name' => '', 'last_name' => 'Doe', 'conflict_of_interest' => 'yes' },
        }
      end

      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'sets the errors with their index' do
        expect(subject).not_to be_valid

        expect(subject.errors.of_kind?('codefendants-attributes[0].last_name', :blank)).to be(true)

        expect(subject.errors.messages_for('codefendants-attributes[0].last_name').first).to eq(
          'Enter last name of co-defendant 1'
        )

        expect(subject.errors.of_kind?('codefendants-attributes[0].conflict_of_interest', :inclusion)).to be(true)

        expect(subject.errors.messages_for('codefendants-attributes[0].conflict_of_interest').first).to eq(
          'Select yes if there is a conflict of interest with co-defendant 1'
        )

        expect(subject.errors.of_kind?('codefendants-attributes[1].first_name', :blank)).to be(true)

        expect(subject.errors.messages_for('codefendants-attributes[1].first_name').first).to eq(
          'Enter first name of co-defendant 2'
        )
      end

      context 'but we are deleting a codefendant' do
        before do
          allow(subject).to receive(:any_marked_for_destruction?).and_return(true)
        end

        it 'does not run the validations' do
          expect(subject).to be_valid
        end
      end
    end

    context 'when there are no errors' do
      it 'saves the record' do
        expect(case_record).to receive(:save).and_return(true)
        expect(subject.save).to be(true)
      end
    end
  end
end
