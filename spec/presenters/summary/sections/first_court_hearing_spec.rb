require 'rails_helper'

describe Summary::Sections::FirstCourtHearing do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      kase: kase,
    )
  end

  let(:kase) do
    instance_double(
      Case,
      first_court_hearing_name:,
    )
  end

  let(:first_court_hearing_name) { 'First court name' }

  describe '#name' do
    it { expect(subject.name).to eq(:first_court_hearing) }
  end

  describe '#show?' do
    context 'when there is a case' do
      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when there is no case' do
      let(:kase) { nil }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    it 'has the correct rows' do
      expect(answers.count).to eq(1)

      expect(answers[0]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[0].question).to eq(:first_court_hearing_name)
      expect(answers[0].change_path).to match('applications/12345/steps/case/first-court-hearing')
      expect(answers[0].value).to eq('First court name')
    end

    context 'when there is no first court hearing' do
      let(:first_court_hearing_name) { nil }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end
end
