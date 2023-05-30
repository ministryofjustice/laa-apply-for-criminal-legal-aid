require 'rails_helper'

RSpec.describe Steps::Client::DetailsForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: applicant_record,
    }.merge(
      form_attributes
    )
  end

  let(:form_attributes) do
    {
      first_name: 'John',
      last_name: 'Doe',
      other_names: nil,
      date_of_birth: Date.yesterday,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, applicant: applicant_record) }
  let(:applicant_record) { Applicant.new }

  describe '#save' do
    context 'validations' do
      it { is_expected.to validate_presence_of(:first_name) }
      it { is_expected.to validate_presence_of(:last_name) }
      it { is_expected.to validate_presence_of(:date_of_birth) }
      it { is_expected.not_to validate_presence_of(:other_names) }
    end

    context 'date_of_birth' do
      it_behaves_like 'a multiparam date validation',
                      attribute_name: :date_of_birth
    end

    context 'when validations pass' do
      let(:applicant_record) { Applicant.new(form_attributes) }

      context 'when any details have changed' do
        let(:form_attributes) { super().merge(last_name: 'Smith') }

        it_behaves_like 'a has-one-association form',
                        association_name: :applicant,
                        expected_attributes: {
                          'first_name' => 'John',
                          'last_name' => 'Smith',
                          'other_names' => nil,
                          'date_of_birth' => Date.yesterday,
                          :has_nino => nil,
                          :nino => nil,
                        }
      end

      context 'when details are the same as in the persisted record' do
        it 'does not save the record but returns true' do
          expect(applicant_record).not_to receive(:update)
          expect(subject.save).to be(true)
        end
      end
    end
  end
end
