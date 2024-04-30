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
      date_of_birth: 20.years.ago.to_date,
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

      context 'when details linked to DWP passporting have changed' do
        context 'last_name' do
          let(:form_attributes) { super().merge(last_name: 'Smith') }

          it_behaves_like 'a has-one-association form',
                          association_name: :applicant,
                          expected_attributes: {
                            'first_name' => 'John',
                            'last_name' => 'Smith',
                            'other_names' => nil,
                            'date_of_birth' => 20.years.ago.to_date,
                            :has_nino => nil,
                            :nino => nil,
                            :benefit_type => nil,
                            :passporting_benefit => nil,
                            :last_jsa_appointment_date => nil,
                            :will_enter_nino => nil,
                            :has_benefit_evidence => nil,
                          }
        end

        context 'date_of_birth' do
          let(:date_of_birth) { 20.years.ago.to_date }
          let(:form_attributes) { super().merge(date_of_birth:) }

          it_behaves_like 'a has-one-association form',
                          association_name: :applicant,
                          expected_attributes: {
                            'first_name' => 'John',
                            'last_name' => 'Doe',
                            'other_names' => nil,
                            'date_of_birth' => 20.years.ago.to_date,
                            :has_nino => nil,
                            :nino => nil,
                            :benefit_type => nil,
                            :passporting_benefit => nil,
                            :last_jsa_appointment_date => nil,
                            :will_enter_nino => nil,
                            :has_benefit_evidence => nil,
                          }
        end
      end

      context 'when details not linked to DWP passporting have changed' do
        let(:form_attributes) { super().merge(first_name: 'Johnny') }

        before do
          allow(applicant_record).to receive(:first_name).and_return('John')
        end

        it 'updates the record without resetting DWP attributes' do
          expect(applicant_record).to receive(:update).with(
            {
              'first_name' => 'Johnny',
              'last_name' => 'Doe',
              'other_names' => nil,
              'date_of_birth' => 20.years.ago.to_date,
            }
          ).and_return(true)

          expect(subject.save).to be(true)
        end
      end

      context 'when details are the same as in the persisted record' do
        it 'does not save the record but returns true' do
          expect(applicant_record).not_to receive(:update)
          expect(subject.save).to be(true)
        end
      end
    end

    context 'when date of birth not valid' do
      context 'when dob is less than 10 years ago' do
        let(:date_of_birth) { 9.years.ago.to_date }
        let(:form_attributes) { super().merge(date_of_birth:) }

        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.added?(:date_of_birth, :client_under_ten)).to be(true)
        end
      end
    end
  end
end
