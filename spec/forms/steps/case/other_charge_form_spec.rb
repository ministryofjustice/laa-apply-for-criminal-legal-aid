require 'rails_helper'

RSpec.describe Steps::Case::OtherChargeForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) { { crime_application: crime_application, record: other_charge }.merge(attributes) }
  let(:crime_application) { CrimeApplication.create(case: kase) }
  let(:kase) { Case.new }
  let(:other_charge) { OtherCharge.new(case: kase, ownership_type: ownership_type) }
  let(:attributes) { {} }
  let(:ownership_type) { SubjectType::APPLICANT.to_s }

  describe 'validations' do
    context 'next_hearing_date' do
      it_behaves_like 'a multiparam date validation',
                      attribute_name: :next_hearing_date,
                      allow_future: true
    end
  end

  describe '#save' do
    let(:attributes) {
      { charge: 'Other charge', hearing_court_name: 'Court', next_hearing_date: Date.new(2024, 9, 23) }
    }

    it 'updates the `charge` field' do
      expect { form.save }.to change(other_charge, :charge).from(nil).to('Other charge')
    end

    it 'updates the `hearing_court_name` field' do
      expect { form.save }.to change(other_charge, :hearing_court_name).from(nil).to('Court')
    end

    it 'updates the `next_hearing_date` field' do
      expect { form.save }.to change(other_charge, :next_hearing_date).from(nil).to(Date.new(2024, 9, 23))
    end
  end

  describe '#form_subject' do
    context 'when ownership_type is `applicant`' do
      let(:ownership_type) { 'applicant' }

      it 'returns the correct SubjectType value' do
        expect(form.form_subject.value).to eq(SubjectType::APPLICANT.value)
      end
    end

    context 'when ownership_type is `partner`' do
      let(:ownership_type) { 'partner' }

      it 'returns the correct SubjectType value' do
        expect(form.form_subject.value).to eq(SubjectType::PARTNER.value)
      end
    end
  end
end
