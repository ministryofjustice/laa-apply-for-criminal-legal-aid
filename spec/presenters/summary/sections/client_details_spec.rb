require 'rails_helper'

describe Summary::Sections::ClientDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      client_has_partner: 'no',
      applicant: applicant,
      application_type: application_type,
      is_means_tested: is_means_tested
    )
  end

  let(:applicant) do
    instance_double(
      Applicant,
      first_name: 'first name',
      last_name: 'last name',
      other_names: '',
      date_of_birth: Date.new(1999, 1, 20),
      nino: nino,
    )
  end

  let(:nino) { '123456' }
  let(:application_type) { ApplicationType::INITIAL }
  let(:pse?) { false }
  let(:has_partner) { 'no' }
  let(:is_means_tested) { 'yes' }

  before do
    allow(applicant).to receive_messages(
      has_partner: has_partner,
      relationship_status: 'separated',
      separation_date: Date.new(2001, 10, 12),
    )

    allow(crime_application).to receive_messages(
      pse?: pse?,
      applicant: applicant,
    )
  end

  describe '#name' do
    it { expect(subject.name).to eq(:client_details) }
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
      expect(answers.count).to eq(8)

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
      expect(answers[3].change_path).to match('applications/12345/steps/client/details')
      expect(answers[3].value).to eq(Date.new(1999, 1, 20))

      expect(answers[4]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[4].question).to eq(:nino)
      expect(answers[4].change_path).to match('applications/12345/steps/client/has_nino')
      expect(answers[4].value).to eq('123456')

      expect(answers[5]).to be_an_instance_of(Summary::Components::ValueAnswer)
      expect(answers[5].question).to eq(:has_partner)
      expect(answers[5].change_path).to match('applications/12345/steps/client/does_client_have_partner')
      expect(answers[5].value).to eq('no')

      expect(answers[6]).to be_an_instance_of(Summary::Components::ValueAnswer)
      expect(answers[6].question).to eq(:relationship_status)
      expect(answers[6].change_path).to match('applications/12345/steps/client/relationship_status')
      expect(answers[6].value).to eq('separated')

      expect(answers[7]).to be_an_instance_of(Summary::Components::DateAnswer)
      expect(answers[7].question).to eq(:separation_date)
      expect(answers[7].change_path).to match('applications/12345/steps/client/relationship_status')
      expect(answers[7].value).to eq(Date.new(2001, 10, 12))
    end

    context 'when there is a partner' do
      let(:has_partner) { 'yes' }

      it 'has the correct rows' do
        expect(answers.count).to eq(6)

        expect(answers[5]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[5].question).to eq(:has_partner)
        expect(answers[5].change_path).to match('applications/12345/steps/client/does_client_have_partner')
        expect(answers[5].value).to eq('yes')
      end
    end

    context 'when there is no `benefit_type` value' do
      let(:benefit_type) { nil }

      it 'has the correct rows' do
        expect(answers.count).to eq(8)
      end
    end

    context 'when application is a post submission evidence application' do
      let(:application_type) { ApplicationType::POST_SUBMISSION_EVIDENCE }
      let(:pse?) { true }

      it 'has the correct rows' do
        expect(answers.count).to eq(7)
      end
    end
  end
end
