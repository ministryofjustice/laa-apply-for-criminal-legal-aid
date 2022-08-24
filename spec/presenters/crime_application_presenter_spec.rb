require 'rails_helper'

RSpec.describe CrimeApplicationPresenter do
  subject { described_class.new(crime_application) }

  let(:crime_application) {
    instance_double(CrimeApplication,
                    id: 'a1234bcd-5dfb-4180-ae5e-91b0fbef468d',
                    created_at: DateTime.new(2022, 01, 12),
                    status: 'in_progress',
                    applicant: applicant)
  }

  let(:applicant) { 
    double(
      Applicant, 
      first_name: 'John', 
      last_name: 'Doe') 
  }

  describe 'when presenting CrimeApplications' do
    it 'delegates full name to applicant' do
      expect(applicant).to receive(:first_name)
      expect(applicant).to receive(:last_name)
      expect(subject.applicant_name).to eq('John Doe')
    end

    it 'can output the subject start date in the correct format' do
      expect(subject.start_date).to eq('12 January 2022')
    end

    it 'has an LAA an reference stubbed' do
      expect(subject.laa_reference).to eq('LAA-a1234b')
    end

    describe 'status tags' do
      it 'can output an in progress tag' do
        tag = '<strong class="govuk-tag govuk-tag--blue">In progress</strong>'
        expect(subject.status_tag).to eq(tag)
      end

      it 'can output an in submitted tag' do
        allow(subject).to receive(:status).and_return('submitted')
        tag = '<strong class="govuk-tag govuk-tag--green">Submitted</strong>'

        expect(subject.status_tag).to eq(tag)
      end
    end
  end
end
