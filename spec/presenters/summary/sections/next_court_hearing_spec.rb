require 'rails_helper'

describe Summary::Sections::NextCourtHearing do
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
      urn: 'xyz',
      hearing_court_name: 'Court name',
      hearing_date: Date.new(2028, 1, 20),
      is_first_court_hearing: is_first_court_hearing,
    )
  end

  let(:is_first_court_hearing) { 'yes' }

  describe '#name' do
    it { expect(subject.name).to eq(:next_court_hearing) }
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
      expect(answers.count).to eq(3)

      expect(answers[0]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[0].question).to eq(:hearing_court_name)
      expect(answers[0].change_path).to match('applications/12345/steps/case/hearing-details')
      expect(answers[0].value).to eq('Court name')

      expect(answers[1]).to be_an_instance_of(Summary::Components::DateAnswer)
      expect(answers[1].question).to eq(:hearing_date)
      expect(answers[1].change_path).to match('applications/12345/steps/case/hearing-details')
      expect(answers[1].value).to eq(Date.new(2028, 1, 20))

      expect(answers[2]).to be_an_instance_of(Summary::Components::ValueAnswer)
      expect(answers[2].question).to eq(:is_first_court_hearing)
      expect(answers[2].change_path).to match('applications/12345/steps/case/hearing-details')
      expect(answers[2].value).to eq('yes')
    end

    context 'when `is_first_court_hearing` attribute is nil' do
      let(:is_first_court_hearing) { nil }

      it 'has the correct rows' do
        expect(answers.count).to eq(2)
      end
    end
  end
end
