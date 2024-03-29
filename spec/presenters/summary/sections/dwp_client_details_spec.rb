require 'rails_helper'

describe Summary::Sections::DWPClientDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      client_has_partner: 'no',
      applicant: applicant,
    )
  end

  let(:applicant) do
    instance_double(
      Applicant,
      first_name: 'first name',
      last_name: 'last name',
      other_names: '',
      date_of_birth: Date.new(1999, 1, 20),
      nino: '123456',
      benefit_type: benefit_type,
    )
  end

  let(:benefit_type) { BenefitType::UNIVERSAL_CREDIT.to_s }

  describe '#name' do
    it { expect(subject.name).to eq(:dwp_client_details) }
  end

  describe '#show?' do
    context 'when there is an applicant' do
      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when there is no applicant' do
      let(:applicant) { nil }

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
      expect(answers[0].question).to eq(:first_name)
      expect(answers[0].change_path).to match('applications/12345/steps/client/details')
      expect(answers[0].value).to eq('first name')

      expect(answers[1]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[1].question).to eq(:last_name)
      expect(answers[1].change_path).to match('applications/12345/steps/client/details')
      expect(answers[1].value).to eq('last name')

      expect(answers[2]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[2].question).to eq(:other_names)
      expect(answers[2].change_path).to match('applications/12345/steps/client/details')
      expect(answers[2].value).to eq('')

      expect(answers[3]).to be_an_instance_of(Summary::Components::DateAnswer)
      expect(answers[3].question).to eq(:date_of_birth)
      expect(answers[2].change_path).to match('applications/12345/steps/client/details')
      expect(answers[3].value).to eq(Date.new(1999, 1, 20))

      expect(answers[4]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[4].question).to eq(:nino)
      expect(answers[4].change_path).to match('applications/12345/steps/client/has_nino')
      expect(answers[4].value).to eq('123456')
    end

    context 'when there is no `benefit_type` value' do
      let(:benefit_type) { nil }

      it 'has the correct rows' do
        expect(answers.count).to eq(5)
      end
    end
  end
end
