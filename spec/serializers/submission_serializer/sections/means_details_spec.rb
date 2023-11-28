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
          }
        }
      }.as_json
    end

    it { expect(subject.generate).to eq(json_output) }
  end

  describe '#lost_job_in_custody' do
    context 'when lost_job_in_custody is nil' do
      let(:income) do
        instance_double(
          Income,
          income_above_threshold: 'yes',
          employment_status: ['not_working'],
          ended_employment_within_three_months: 'no',
          lost_job_in_custody: nil,
          date_job_lost: nil,
        )
      end

      let(:json_output) do
        {
          means_details: {
            income_details: {
              income_above_threshold: 'yes',
              employment_type: ['not_working'],
              ended_employment_within_three_months: 'no'
            }
          }
        }.as_json
      end

      it 'does not output lost_job_in_custody_fields' do
        expect(subject.generate).to eq(json_output)
      end
    end
  end
end
