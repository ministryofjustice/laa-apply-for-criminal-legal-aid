require 'rails_helper'

RSpec.describe CrimeApplicationPresenter do
  include ApplicationHelper

  let(:presented_application) { 
    present(
      CrimeApplication.new(
        status: 'in_progress', 
        created_at: DateTime.new(2022, 01, 12))
    ) 
  }

  let(:applicant) { double(Applicant, full_name: 'John Doe') }

  describe 'when presenting CrimeApplications' do
    it 'delegates full name to applicant' do
      allow(presented_application).to receive(:applicant).and_return(applicant)

      expect(applicant).to receive(:full_name)
      expect(presented_application.full_name).to eq('John Doe')
    end

    it 'can output the presented_application start date in the correct format' do
      expect(presented_application.start_date).to eq('12 January 2022')
    end

    it 'has an LAA an reference stubbed' do
      expect(presented_application.laa_reference).to eq('LAA-a1234b')
    end

    describe 'status tags' do
      it 'can output an in progress tag' do
        tag = '<strong class="govuk-tag govuk-tag--blue">In progress</strong>'
        expect(presented_application.status_tag).to eq(tag)
      end

      it 'can output an in submitted tag' do
        allow(presented_application).to receive(:status).and_return('submitted')
        tag = '<strong class="govuk-tag govuk-tag--green">Submitted</strong>'

        expect(presented_application.status_tag).to eq(tag)
      end
    end
  end
end
