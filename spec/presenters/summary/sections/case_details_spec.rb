require 'rails_helper'

describe Summary::Sections::CaseDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      case: kase,
    )
  end

  let(:kase) do
    instance_double(
      Case,
      urn: 'xyz',
      case_type: 'foobar',
    )
  end

  describe '#name' do
    it { expect(subject.name).to eq(:case_details) }
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    it 'has the correct rows' do
      expect(answers.count).to eq(2)

      expect(answers[0]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[0].question).to eq(:case_urn)
      expect(answers[0].change_path).to match('applications/12345/steps/case/urn')
      expect(answers[0].value).to eq('xyz')

      expect(answers[1]).to be_an_instance_of(Summary::Components::ValueAnswer)
      expect(answers[1].question).to eq(:case_type)
      expect(answers[1].change_path).to match('applications/12345/steps/case/case_type')
      expect(answers[1].value).to eq('foobar')
    end
  end
end
