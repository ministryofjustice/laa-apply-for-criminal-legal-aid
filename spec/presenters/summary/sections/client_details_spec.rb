require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
describe Summary::Sections::ClientDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      applicant: applicant,
      application_type: application_type,
      is_means_tested: is_means_tested,
      means_passport: means_passport
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
      arc: arc
    )
  end

  let(:nino) { '123456' }
  let(:has_nino) { 'yes' }
  let(:arc) { nil }
  let(:has_arc) { nil }
  let(:application_type) { ApplicationType::INITIAL }
  let(:pse?) { false }
  let(:appeal_no_changes?) { false }
  let(:means_passport) { [] }
  let(:has_partner) { 'no' }
  let(:is_means_tested) { 'yes' }

  before do
    allow(applicant).to receive_messages(
      has_partner: has_partner,
      relationship_status: 'separated',
      separation_date: Date.new(2001, 10, 12),
      has_nino: has_nino,
      has_arc: has_arc
    )

    allow(crime_application).to receive_messages(
      pse?: pse?,
      appeal_no_changes?: appeal_no_changes?,
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
      expect(answers[4].change_path).to match('applications/12345/steps/client/nino')
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

    context 'when an arc is provided' do
      let(:nino) { nil }
      let(:has_arc) { 'yes' }
      let(:arc) { 'ABC12/345678/A' }

      it 'has the correct rows' do
        expect(answers.count).to eq(9)

        expect(answers[4]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[4].question).to eq(:nino)
        expect(answers[4].change_path).to match('applications/12345/steps/client/nino')
        expect(answers[4].value).to be_nil

        expect(answers[5]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[5].question).to eq(:arc)
        expect(answers[5].change_path).to match('applications/12345/steps/client/nino')
        expect(answers[5].value).to eq('ABC12/345678/A')
      end
    end

    context 'when application is a post submission evidence application' do
      let(:application_type) { ApplicationType::POST_SUBMISSION_EVIDENCE }
      let(:pse?) { true }

      it 'has the correct rows' do
        expect(answers.count).to eq(7)
      end
    end

    context 'when application is a appeal no changes application' do
      let(:appeal_no_changes?) { true }

      it 'has the correct rows' do
        expect(answers.count).to eq(7)
      end
    end

    context 'when application is an under 18 application' do
      let(:means_passport) { ['on_age_under18'] }

      it 'has the correct rows' do
        expect(answers.count).to eq(7)
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
