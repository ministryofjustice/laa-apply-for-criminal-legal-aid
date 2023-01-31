require 'rails_helper'

describe Summary::Sections::Overview do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      status: status,
      reference: 12_345,
      date_stamp: Date.new(2023, 1, 20),
      submitted_at: Date.new(2023, 1, 21),
      provider_details: provider_details,
    )
  end

  let(:provider_details) { double }
  let(:status) { :submitted }

  before do
    allow(crime_application).to receive(:in_progress?).and_return(false)
    allow(provider_details).to receive(:provider_email).and_return('provider@example.com')
    allow(provider_details).to receive(:office_code).and_return('123AA')
  end

  describe '#name' do
    it { expect(subject.name).to eq(:overview) }
  end

  describe '#show?' do
    context 'when the application has been submitted' do
      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when the application is in_progress' do
      let(:status) { :in_progress }

      before do
        allow(crime_application).to receive(:in_progress?).and_return(true)
      end

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    it 'has the correct rows' do
      expect(answers.count).to eq(5)

      expect(answers[0]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[0].question).to eq(:reference)
      expect(answers[0].value).to eq('12345')

      expect(answers[1]).to be_an_instance_of(Summary::Components::DateAnswer)
      expect(answers[1].question).to eq(:date_stamp)
      expect(answers[1].value).to eq(Date.new(2023, 1, 20))

      expect(answers[2]).to be_an_instance_of(Summary::Components::DateAnswer)
      expect(answers[2].question).to eq(:date_submitted)
      expect(answers[2].value).to eq(Date.new(2023, 1, 21))

      expect(answers[3]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[3].question).to eq(:provider_email)
      expect(answers[3].value).to eq('provider@example.com')

      expect(answers[4]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[4].question).to eq(:office_code)
      expect(answers[4].value).to eq('123AA')
    end
  end
end
