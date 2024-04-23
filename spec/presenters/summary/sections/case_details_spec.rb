require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
describe Summary::Sections::CaseDetails do
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
      urn:,
      case_type:,
      has_case_concluded:,
      date_case_concluded:,
      is_preorder_work_claimed:,
      preorder_work_date:,
      preorder_work_details:,
      is_client_remanded:,
      date_client_remanded:,
      appeal_lodged_date:,
      appeal_original_app_submitted:,
      appeal_financial_circumstances_changed:,
      appeal_with_changes_details:,
      appeal_reference_number:,
      appeal_maat_id:,
      appeal_usn:,
    )
  end

  let(:case_type) { 'foobar' }
  let(:appeal_lodged_date) { nil }
  let(:appeal_original_app_submitted) { nil }
  let(:appeal_financial_circumstances_changed) { nil }
  let(:appeal_with_changes_details) { nil }
  let(:appeal_reference_number) { nil }
  let(:appeal_maat_id) { nil }
  let(:appeal_usn) { nil }
  let(:means_passport) { [] }
  let(:urn) { 'xyz' }

  let(:has_case_concluded) { nil }
  let(:date_case_concluded) { nil }
  let(:is_client_remanded) { nil }
  let(:date_client_remanded) { nil }
  let(:is_preorder_work_claimed) { nil }
  let(:preorder_work_date) { nil }
  let(:preorder_work_details) { nil }

  before do
    allow(crime_application).to receive(:means_passport).and_return(means_passport)
  end

  describe '#name' do
    it { expect(subject.name).to eq(:case_details) }
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

    context "when has_case_concluded=='no'" do
      let(:has_case_concluded) { 'no' }

      it 'has the correct rows' do
        expect(answers.count).to eq(3)

        answer = answers[0]
        expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answer.question).to eq(:case_urn)
        expect(answer.change_path).to match('applications/12345/steps/case/urn')
        expect(answer.value).to eq('xyz')

        answer = answers[1]
        expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answer.question).to eq(:case_type)
        expect(answer.change_path).to match('applications/12345/steps/client/case_type')
        expect(answer.value).to eq('foobar')

        answer = answers[2]
        expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answer.question).to eq(:has_case_concluded)
        expect(answer.change_path).to match('applications/12345/steps/case/has_the_case_concluded')
        expect(answer.value).to eq('no')
      end
    end

    context "when has_case_concluded=='yes'" do
      let(:has_case_concluded) { 'yes' }
      let(:date_case_concluded) { Time.zone.today }

      it 'has the correct rows' do
        expect(answers.count).to eq(4)

        answer = answers[0]
        expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answer.question).to eq(:case_urn)
        expect(answer.change_path).to match('applications/12345/steps/case/urn')
        expect(answer.value).to eq('xyz')

        answer = answers[1]
        expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answer.question).to eq(:case_type)
        expect(answer.change_path).to match('applications/12345/steps/client/case_type')
        expect(answer.value).to eq('foobar')

        answer = answers[2]
        expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answer.question).to eq(:has_case_concluded)
        expect(answer.change_path).to match('applications/12345/steps/case/has_the_case_concluded')
        expect(answer.value).to eq('yes')

        answer = answers[3]
        expect(answer).to be_an_instance_of(Summary::Components::DateAnswer)
        expect(answer.question).to eq(:date_case_concluded)
        expect(answer.change_path).to match('applications/12345/steps/case/has_the_case_concluded')
        expect(answer.value).to eq(date_case_concluded)
      end
    end

    context "when is_preorder_work_claimed=='no'" do
      let(:has_case_concluded) { 'no' }
      let(:date_case_concluded) { nil }

      let(:is_preorder_work_claimed) { 'no' }
      let(:preorder_work_date) { nil }
      let(:preorder_work_details) { nil }

      let(:is_client_remanded) { 'no' }
      let(:date_client_remanded) { nil }

      it 'has the correct rows' do
        expect(answers.count).to eq(5)

        answer = answers[3]
        expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answer.question).to eq(:is_preorder_work_claimed)
        expect(answer.change_path).to match('applications/12345/steps/case/claim_pre_order_work')
        expect(answer.value).to eq('no')

        answer = answers[4]
        expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answer.question).to eq(:is_client_remanded)
        expect(answer.change_path).to match('applications/12345/steps/case/has_court_remanded_client_in_custody')
        expect(answer.value).to eq('no')
      end
    end

    context "when is_preorder_work_claimed=='yes'" do
      let(:has_case_concluded) { 'no' }
      let(:date_case_concluded) { nil }

      let(:is_preorder_work_claimed) { 'yes' }
      let(:preorder_work_date) {  Time.zone.today }
      let(:preorder_work_details) { 'details' }

      let(:is_client_remanded) { 'yes' }
      let(:date_client_remanded) { Time.zone.today }

      it 'has the correct rows' do
        expect(answers.count).to eq(8)

        answer = answers[3]
        expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answer.question).to eq(:is_preorder_work_claimed)
        expect(answer.change_path).to match('applications/12345/steps/case/claim_pre_order_work')
        expect(answer.value).to eq('yes')

        answer = answers[4]
        expect(answer).to be_an_instance_of(Summary::Components::DateAnswer)
        expect(answer.question).to eq(:preorder_work_date)
        expect(answer.change_path).to match('applications/12345/steps/case/claim_pre_order_work')
        expect(answer.value).to eq(preorder_work_date)

        answer = answers[5]
        expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answer.question).to eq(:preorder_work_details)
        expect(answer.change_path).to match('applications/12345/steps/case/claim_pre_order_work')
        expect(answer.value).to eq(preorder_work_details)
      end
    end

    context "when is_client_remanded=='no'" do
      let(:has_case_concluded) { 'no' }
      let(:date_case_concluded) { nil }
      let(:is_client_remanded) { 'no' }
      let(:date_client_remanded) { nil }

      it 'has the correct rows' do
        expect(answers.count).to eq(4)

        answer = answers[0]
        expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answer.question).to eq(:case_urn)
        expect(answer.change_path).to match('applications/12345/steps/case/urn')
        expect(answer.value).to eq('xyz')

        answer = answers[1]
        expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answer.question).to eq(:case_type)
        expect(answer.change_path).to match('applications/12345/steps/client/case_type')
        expect(answer.value).to eq('foobar')

        answer = answers[2]
        expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answer.question).to eq(:has_case_concluded)
        expect(answer.change_path).to match('applications/12345/steps/case/has_the_case_concluded')
        expect(answer.value).to eq('no')

        answer = answers[3]
        expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answer.question).to eq(:is_client_remanded)
        expect(answer.change_path).to match('applications/12345/steps/case/has_court_remanded_client_in_custody')
        expect(answer.value).to eq('no')
      end
    end

    context "when is_client_remanded=='yes'" do
      let(:has_case_concluded) { 'no' }
      let(:date_case_concluded) { nil }
      let(:is_client_remanded) { 'yes' }
      let(:date_client_remanded) { Time.zone.today }

      it 'has the correct rows' do
        expect(answers.count).to eq(5)

        answer = answers[0]
        expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answer.question).to eq(:case_urn)
        expect(answer.change_path).to match('applications/12345/steps/case/urn')
        expect(answer.value).to eq('xyz')

        answer = answers[1]
        expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answer.question).to eq(:case_type)
        expect(answer.change_path).to match('applications/12345/steps/client/case_type')
        expect(answer.value).to eq('foobar')

        answer = answers[2]
        expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answer.question).to eq(:has_case_concluded)
        expect(answer.change_path).to match('applications/12345/steps/case/has_the_case_concluded')
        expect(answer.value).to eq('no')

        answer = answers[3]
        expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answer.question).to eq(:is_client_remanded)
        expect(answer.change_path).to match('applications/12345/steps/case/has_court_remanded_client_in_custody')
        expect(answer.value).to eq('yes')

        answer = answers[4]
        expect(answer).to be_an_instance_of(Summary::Components::DateAnswer)
        expect(answer.question).to eq(:date_client_remanded)
        expect(answer.change_path).to match('applications/12345/steps/case/has_court_remanded_client_in_custody')
        expect(answer.value).to eq(date_client_remanded)
      end
    end

    context 'for appeal to crown court' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT }
      let(:appeal_lodged_date) { Date.new(2018, 11, 22) }

      context 'when appeal_original_app_submitted==no' do
        before do
          allow(kase).to receive(:appeal_original_app_submitted?).and_return(false)
        end

        let(:appeal_original_app_submitted) { YesNoAnswer::NO.to_s }

        it 'has the correct rows' do
          expect(answers.count).to eq(4)

          answer = answers[0]
          expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answer.question).to eq(:case_urn)
          expect(answer.change_path).to match('applications/12345/steps/case/urn')
          expect(answer.value).to eq('xyz')

          answer = answers[1]
          expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answer.question).to eq(:case_type)
          expect(answer.change_path).to match('applications/12345/steps/client/case_type')
          expect(answer.value).to eq(case_type)

          answer = answers[2]
          expect(answer).to be_an_instance_of(Summary::Components::DateAnswer)
          expect(answer.question).to eq(:appeal_lodged_date)
          expect(answer.change_path).to match('applications/12345/steps/client/appeal_details')
          expect(answer.value).to eq(appeal_lodged_date)

          answer = answers[3]
          expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answer.question).to eq(:appeal_original_app_submitted)
          expect(answer.change_path).to match('applications/12345/steps/client/appeal_details')
          expect(answer.value).to eq(appeal_original_app_submitted)
        end
      end

      context 'when appeal_financial_circumstances_changed==yes' do
        before do
          allow(kase).to receive(:appeal_original_app_submitted?).and_return(true)
        end

        let(:appeal_original_app_submitted) { YesNoAnswer::YES.to_s }
        let(:appeal_financial_circumstances_changed) { YesNoAnswer::YES.to_s }
        let(:appeal_with_changes_details) { 'change in financial circumstances details' }

        it 'has the correct rows' do
          expect(answers.count).to eq(6)

          answer = answers[3]
          expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answer.question).to eq(:appeal_original_app_submitted)
          expect(answer.change_path).to match('applications/12345/steps/client/appeal_details')
          expect(answer.value).to eq(appeal_original_app_submitted)

          answer = answers[4]
          expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answer.question).to eq(:appeal_financial_circumstances_changed)
          expect(answer.change_path).to match('applications/12345/steps/client/financial_circumstances_changed')
          expect(answer.value).to eq(appeal_financial_circumstances_changed)

          answer = answers[5]
          expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answer.question).to eq(:appeal_with_changes_details)
          expect(answer.change_path).to match('applications/12345/steps/client/financial_circumstances_changed')
          expect(answer.value).to eq(appeal_with_changes_details)
        end
      end

      context 'when appeal_financial_circumstances_changed==no' do
        before do
          allow(kase).to receive(:appeal_original_app_submitted?).and_return(true)
        end

        let(:appeal_original_app_submitted) { YesNoAnswer::YES.to_s }
        let(:appeal_financial_circumstances_changed) { YesNoAnswer::NO.to_s }

        context 'with MAAT ID' do
          let(:appeal_reference_number) { 'appeal_maat_id' }
          let(:appeal_maat_id) { '123456' }

          it 'has the correct rows' do
            expect(answers.count).to eq(6)

            answer = answers[3]
            expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
            expect(answer.question).to eq(:appeal_original_app_submitted)
            expect(answer.change_path).to match('applications/12345/steps/client/appeal_details')
            expect(answer.value).to eq(appeal_original_app_submitted)

            answer = answers[4]
            expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
            expect(answer.question).to eq(:appeal_financial_circumstances_changed)
            expect(answer.change_path).to match('applications/12345/steps/client/financial_circumstances_changed')
            expect(answer.value).to eq(appeal_financial_circumstances_changed)

            answer = answers[5]
            expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
            expect(answer.question).to eq(:appeal_maat_id_or_usn)
            expect(answer.change_path).to match('applications/12345/steps/client/appeal_reference_number')
            expect(answer.value).to eq(appeal_maat_id)
          end
        end

        context 'with USN' do
          let(:appeal_reference_number) { 'appeal_usn' }
          let(:appeal_usn) { '123456' }

          it 'has the correct rows' do
            expect(answers.count).to eq(6)

            answer = answers[5]
            expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
            expect(answer.question).to eq(:appeal_maat_id_or_usn)
            expect(answer.change_path).to match('applications/12345/steps/client/appeal_reference_number')
            expect(answer.value).to eq(appeal_usn)
          end
        end
      end
    end

    context 'when application is not means tested' do
      let(:means_passport) { ['on_not_means_tested'] }
      let(:case_type) { nil }

      it 'has the correct rows' do
        expect(answers.count).to eq(1)

        answer = answers[0]
        expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answer.question).to eq(:case_urn)
        expect(answer.change_path).to match('applications/12345/steps/case/urn')
        expect(answer.value).to eq('xyz')
      end
      # rubocop:enable RSpec/MultipleMemoizedHelpers
    end
  end
end
