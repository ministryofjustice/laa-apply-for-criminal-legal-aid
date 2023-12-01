require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::MeansDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(CrimeApplication, income:)
  end

  describe '#generate' do
    let(:income) do
      instance_double(
        Income,
        income_above_threshold: 'yes',
        employment_status: ['not_working'],
        ended_employment_within_three_months: 'yes',
        lost_job_in_custody: 'yes',
        date_job_lost: '2023-10-01',
        manage_without_income: 'other',
        manage_other_details: 'Another way that they manage'
      )
    end

    let(:json_output) do
      {
        means_details: {
          income_details: {
            income_above_threshold: 'yes',
            employment_type: ['not_working'],
            ended_employment_within_three_months: 'yes',
            lost_job_in_custody: 'yes',
            date_job_lost: '2023-10-01',
            manage_without_income: 'other',
            manage_other_details: 'Another way that they manage'
          }
        }
      }.as_json
    end

    it { expect(subject.generate).to eq(json_output) }
  end

  context 'when optional fields are not supplied' do
    let(:income) do
      instance_double(
        Income,
        income_above_threshold: 'yes',
        employment_status: ['not_working'],
        ended_employment_within_three_months: nil,
        lost_job_in_custody: nil,
        date_job_lost: nil,
        manage_without_income: nil,
        manage_other_details: nil
      )
    end

    let(:json_output) do
      {
        means_details: {
          income_details: {
            income_above_threshold: 'yes',
            employment_type: ['not_working'],
            ended_employment_within_three_months: nil,
            lost_job_in_custody: nil,
            date_job_lost: nil,
            manage_without_income: nil,
            manage_other_details: nil,
          }
        }
      }.as_json
    end

    it 'does not output lost_job_in_custody_fields' do
      expect(subject.generate).to eq(json_output)
    end
  end
end
