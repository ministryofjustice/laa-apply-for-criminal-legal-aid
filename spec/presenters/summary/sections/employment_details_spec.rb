require 'rails_helper'

describe Summary::Sections::EmploymentDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      income: income,
    )
  end

  let(:income) do
    instance_double(
      Income,
      employment_status:,
      ended_employment_within_three_months:,
      lost_job_in_custody:,
      date_job_lost:,
      client_in_armed_forces:,
    )
  end

  let(:employment_status) { ['not_working'] }
  let(:ended_employment_within_three_months) { 'yes' }
  let(:lost_job_in_custody) { 'yes' }
  let(:date_job_lost) { Date.new(2023, 11, 20) }
  let(:client_in_armed_forces) { nil }

  describe '#name' do
    it { expect(subject.name).to eq(:employment_details) }
  end

  describe '#show?' do
    context 'when there is an income_details' do
      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when there is no income_details' do
      let(:income) { nil }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when there are income details' do
      context 'and the client is not working' do
        let(:employment_status) { ['not_working'] }

        it 'has the correct rows' do
          expect(answers.count).to eq(4)
          expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[0].question).to eq(:employment_status)
          expect(answers[0].change_path).to match('applications/12345/steps/income/what-is-clients-employment-status')
          expect(answers[0].value).to eq('not_working')
          expect(answers[1]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[1].question).to eq(:ended_employment_within_three_months)
          expect(answers[1].change_path).to match('applications/12345/steps/income/what-is-clients-employment-status')
          expect(answers[1].value).to eq('yes')
          expect(answers[2]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[2].question).to eq(:lost_job_in_custody)
          expect(answers[2].change_path)
            .to match('applications/12345/steps/income/did-client-lose-job-being-in-custody')
          expect(answers[2].value).to eq('yes')
          expect(answers[3]).to be_an_instance_of(Summary::Components::DateAnswer)
          expect(answers[3].question).to eq(:date_job_lost)
          expect(answers[3].change_path)
            .to match('applications/12345/steps/income/did-client-lose-job-being-in-custody')
          expect(answers[3].value).to eq(Date.new(2023, 11, 20))
        end
      end

      context 'and the client is employed' do
        let(:employment_status) { ['employed'] }
        let(:ended_employment_within_three_months) { nil }
        let(:lost_job_in_custody) { nil }
        let(:date_job_lost) { nil }
        let(:client_in_armed_forces) { 'no' }

        it 'has the correct rows' do
          expect(answers.count).to eq(2)
          expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[0].question).to eq(:employment_status)
          expect(answers[0].change_path).to match('applications/12345/steps/income/what-is-clients-employment-status')
          expect(answers[0].value).to eq('employed')
          expect(answers[1]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[1].question).to eq(:client_in_armed_forces)
          expect(answers[1].change_path).to match('applications/12345/steps/income/client/armed-forces')
          expect(answers[1].value).to eq('no')
        end
      end
    end
  end
end
