require 'rails_helper'

RSpec.describe Steps::Income::DependantsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      dependants_attributes:,
    }
  end

  let(:crime_application) { CrimeApplication.new(case: case_record, income: income_record) }
  let(:case_record) { Case.new }
  let(:income_record) { Income.new }

  let(:dependants_attributes) do
    {
      '0' => { 'age' => 17 },
      '1' => { 'age' => 0 },
      '2' => { 'age' => 2 },
    }
  end

  describe '#dependants' do
    context 'when there are no dependants' do
      let(:dependants_attributes) { {} }

      it 'returns an empty collection' do
        expect(subject.dependants).to eq([])
      end
    end

    context 'when there are existing dependants' do
      it 'builds a collection of `DependantFieldsetForm` instances' do
        expect(subject.dependants[0]).to be_an_instance_of(Steps::Income::DependantFieldsetForm)
        expect(subject.dependants[1]).to be_an_instance_of(Steps::Income::DependantFieldsetForm)

        expect(subject.dependants[0].age).to eq(17)
        expect(subject.dependants[1].age).to eq(0)
      end
    end

    context 'when there are 50 dependants' do
      let(:dependants_attributes) do
        Array.new(50) { |i| [i.to_s, { 'age' => 5 }] }.to_h
      end

      it 'is valid' do
        expect(subject.crime_application.dependants.size).to eq 50
        expect(subject).to be_valid
      end
    end

    context 'when there are 51 or more dependants' do
      let(:dependants_attributes) do
        Array.new(51) { |i| [i.to_s, { 'age' => 5 }] }.to_h
      end

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?('dependants', :too_long)).to be(true)
      end
    end
  end

  describe '#any_marked_for_destruction?' do
    context 'there are records marked for destruction' do
      let(:application) { CrimeApplication.create }
      let(:case_record) { Case.create(crime_application: application) }
      let(:dependant) { Dependant.create(crime_application: crime_application, age: 6) }

      let(:dependants_attributes) do
        {
          '0' => dependant.slice(:id, :age).merge(_destroy: '1'),
          '1' => { age: 12 },
        }
      end

      it 'returns true' do
        expect(subject.any_marked_for_destruction?).to be(true)

        expect(subject.dependants[0]._destroy).to be(true)
        expect(subject.dependants[1]._destroy).to be(false)
      end
    end

    context 'there are no records to be destroyed' do
      it { expect(subject.any_marked_for_destruction?).to be(false) }
    end
  end

  describe '#show_destroy?' do
    context 'there is only 1 dependant' do
      let(:dependants_attributes) { { '0' => { 'age' => 15 } } }

      it { expect(subject.show_destroy?).to be(false) }
    end

    context 'there are more than 1 dependants' do
      it { expect(subject.show_destroy?).to be(true) }
    end
  end

  describe '#save' do
    context 'with invalid age' do
      let(:dependants_attributes) do
        {
          '0' => { age: '90' },
          '1' => { age: '-1' },
        }
      end

      it 'does not save' do
        expect(subject.save).to be(false)
      end

      it 'sets the errors with their index' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?('dependants-attributes[0].age', :less_than)).to be(true)
      end

      it 'responds to virtual attribute' do
        expect(subject).not_to be_valid
        expect(subject.send(:'dependants-attributes[0].age')).to eq(90)
        expect(subject.send(:'dependants-attributes[1].age')).to eq(-1)
      end

      context 'when deleting a dependant' do
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
        expect(crime_application).to receive(:save).and_return(true)
        expect(subject.save).to be(true)
      end
    end
  end
end
