require 'rails_helper'

RSpec.describe Steps::Case::CodefendantsForm do
  let(:arguments) { {
    crime_application: crime_application,
    codefendants_attributes: codefendants_attributes,
  } }

  let(:crime_application) { instance_double(CrimeApplication, case: case_record) }
  let(:case_record) { Case.new }

  let(:codefendants_attributes) {
    {
      "0"=>{"first_name"=>"John", "last_name"=>"Doe"},
      "1"=>{"first_name"=>"Jane", "last_name"=>"Doe"},
    }
  }

  subject { described_class.new(arguments) }

  describe '#codefendants' do
    # TODO: temporary until we have previous step
    context 'there are no codefendants' do
      let(:codefendants_attributes) { {} }

      it 'adds a blank one to the collection' do
        expect(case_record.codefendants).to receive(:create!)
        subject.codefendants
      end
    end

    # TODO: temporary until we have previous step
    context 'there are existing codefendants' do
      it 'does not add a blank one to the collection' do
        expect(subject).not_to receive(:add_blank_codefendant)
        subject.codefendants
      end

      it 'builds a collection of `CodefendantFieldsetForm` instances' do
        expect(
          subject.codefendants
        ).to contain_exactly(Steps::Case::CodefendantFieldsetForm, Steps::Case::CodefendantFieldsetForm)

        expect(subject.codefendants[0].first_name).to eq('John')
        expect(subject.codefendants[0].last_name).to eq('Doe')

        expect(subject.codefendants[1].first_name).to eq('Jane')
        expect(subject.codefendants[1].last_name).to eq('Doe')
      end
    end
  end

  describe '#save' do
    context 'when there are errors in any of the codefendants' do
      let(:codefendants_attributes) {
        {
          "0"=>{"first_name"=>"John", "last_name"=>""},
          "1"=>{"first_name"=>"", "last_name"=>"Doe"},
        }
      }

      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'sets the errors with their index' do
        expect(subject).to_not be_valid

        expect(subject.errors.of_kind?('codefendants-attributes[0].last_name', :blank)).to eq(true)
        expect(subject.errors.messages_for('codefendants-attributes[0].last_name').first).to eq('Enter last name of co-defendant 1')

        expect(subject.errors.of_kind?('codefendants-attributes[1].first_name', :blank)).to eq(true)
        expect(subject.errors.messages_for('codefendants-attributes[1].first_name').first).to eq('Enter first name of co-defendant 2')
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
