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
      lost_job_in_custody: 'yes',
      date_job_lost: Date.new(2023, 11, 20),
    )
  end

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
      it 'has the correct rows' do
        expect(answers.count).to eq(2)
        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:lost_job_in_custody)
        expect(answers[0].change_path).to match('applications/12345/steps/income/did_client_lose_job_being_in_custody')
        expect(answers[0].value).to eq('yes')
        expect(answers[1]).to be_an_instance_of(Summary::Components::DateAnswer)
        expect(answers[1].question).to eq(:date_job_lost)
        expect(answers[1].change_path).to match('applications/12345/steps/income/did_client_lose_job_being_in_custody')
        expect(answers[1].value).to eq(Date.new(2023, 11, 20))
      end
    end
  end
end
