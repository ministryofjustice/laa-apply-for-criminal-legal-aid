require 'rails_helper'

RSpec.describe Steps::Income::BusinessTypeForm do
  subject(:form) { described_class.new(crime_application: crime_application, record: record, subject: form_subject) }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:record) { instance_double(Business) }
  let(:form_subject) { applicant }
  let(:applicant) { Applicant.new }

  describe '#choices' do
    subject(:choices) { form.choices }

    it { is_expected.to eq(BusinessType.values) }
  end

  describe '#validations' do
    it { is_expected.to validate_is_a(:business_type, BusinessType) }
  end

  describe 'save' do
    let(:business_type) { BusinessType.values.sample }

    before do
      allow(Business).to receive(:create!).and_return(true)

      form.business_type = business_type
      form.save
    end

    context 'when the form subject is applicant' do
      it 'create a new business with the ownership type from the subject' do
        expect(Business).to have_received(:create!).with(
          crime_application: crime_application,
          business_type: business_type,
          ownership_type: OwnershipType::APPLICANT
        )
      end
    end

    context 'when the form subject is the partner' do
      let(:form_subject) { Partner.new }

      it 'create a new business with the ownership type from the subject' do
        expect(Business).to have_received(:create!).with(
          crime_application: crime_application,
          business_type: business_type,
          ownership_type: OwnershipType::PARTNER
        )
      end
    end

    context 'when the form subject does not have an ownership type' do
      let(:form_subject) { double(:other_subject, ownership_type: nil) }

      it 'create a new business with the ownership type from the subject' do
        expect(Business).not_to have_received(:create!)
      end
    end
  end
end
