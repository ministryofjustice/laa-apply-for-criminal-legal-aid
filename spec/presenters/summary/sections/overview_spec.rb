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
      application_type: application_type,
      pre_cifc_reference_number: pre_cifc_reference_number,
      pre_cifc_maat_id: pre_cifc_maat_id,
      pre_cifc_usn: pre_cifc_usn,
      pre_cifc_reason: pre_cifc_reason,
    )
  end

  let(:provider_details) { double }
  let(:status) { :submitted }
  let(:application_type) { 'initial' }
  let(:pre_cifc_reference_number) { nil }
  let(:pre_cifc_maat_id) { nil }
  let(:pre_cifc_usn) { nil }
  let(:pre_cifc_reason) { nil }

  before do
    allow(crime_application).to receive_messages(kase: Case.new, in_progress?: false, is_means_tested: 'yes')
    allow(provider_details).to receive_messages(provider_email: 'provider@example.com', office_code: '123AA')
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
        expect(subject.show?).to be(true)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when the application is completed' do
      it 'has the correct rows' do
        expect(answers.count).to eq(7)

        answer = answers[0]
        expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answer.question).to eq(:application_type)
        expect(answer.value).to eq('initial')

        answer = answers[1]
        expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answer.question).to eq(:reference)
        expect(answer.value).to eq('12345')

        answer = answers[2]
        expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answer.question).to eq(:means_tested)
        expect(answer.change_path).to match('applications/12345/steps/client/is-application-means-tested')
        expect(answer.value).to eq('yes')

        answer = answers[3]
        expect(answer).to be_an_instance_of(Summary::Components::DateAnswer)
        expect(answer.question).to eq(:date_stamp)
        expect(answer.value).to eq(Date.new(2023, 1, 20))

        answer = answers[4]
        expect(answer).to be_an_instance_of(Summary::Components::DateAnswer)
        expect(answer.question).to eq(:date_submitted)
        expect(answer.value).to eq(Date.new(2023, 1, 21))

        answer = answers[5]
        expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answer.question).to eq(:provider_email)
        expect(answer.value).to eq('provider@example.com')

        answer = answers[6]
        expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answer.question).to eq(:office_code)
        expect(answer.value).to eq('123AA')
      end

      context 'when application_type is pse' do
        let(:application_type) { 'post_submission_evidence' }

        it 'has the correct rows' do
          expect(answers.count).to eq(5)

          answer = answers[0]
          expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answer.question).to eq(:application_type)
          expect(answer.value).to eq('post_submission_evidence')

          answer = answers[1]
          expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answer.question).to eq(:reference)
          expect(answer.value).to eq('12345')

          answer = answers[2]
          expect(answer).to be_an_instance_of(Summary::Components::DateAnswer)
          expect(answer.question).to eq(:date_submitted)
          expect(answer.value).to eq(Date.new(2023, 1, 21))

          answer = answers[3]
          expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answer.question).to eq(:provider_email)
          expect(answer.value).to eq('provider@example.com')

          answer = answers[4]
          expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answer.question).to eq(:office_code)
          expect(answer.value).to eq('123AA')
        end
      end
    end

    context 'when the application is in_progress' do
      before do
        allow(crime_application).to receive(:in_progress?).and_return(true)
      end

      it 'has the correct rows' do
        expect(answers.count).to eq(3)

        answer = answers[1]
        expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answer.question).to eq(:reference)
        expect(answer.value).to eq('12345')

        answer = answers[2]
        expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answer.question).to eq(:means_tested)
        expect(answer.change_path).to match('applications/12345/steps/client/is-application-means-tested')
        expect(answer.value).to eq('yes')
      end

      context 'when application_type is pse' do
        let(:application_type) { 'post_submission_evidence' }

        it 'has the correct rows' do
          expect(answers.count).to eq(2)

          answer = answers[1]
          expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answer.question).to eq(:reference)
          expect(answer.value).to eq('12345')
        end
      end

      context 'when application_type is change in financial circumstances' do
        let(:application_type) { 'change_in_financial_circumstances' }

        context 'with reason' do
          let(:pre_cifc_reason) { 'Won the lottery' }

          it 'has the correct rows' do
            expect(answers.count).to eq(4)

            answer = answers[2]
            expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
            expect(answer.question).to eq(:pre_cifc_reason)
            expect(answer.change_path).to match('applications/12345/steps/circumstances/pre-cifc-reason')
            expect(answer.value).to eq('Won the lottery')
          end
        end

        context 'with MAAT ID' do
          let(:pre_cifc_reference_number) { 'pre_cifc_maat_id' }
          let(:pre_cifc_maat_id) { '123456' }

          it 'has the correct rows' do
            expect(answers.count).to eq(4)

            answer = answers[3]
            expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
            expect(answer.question).to eq(:pre_cifc_maat_id_or_usn)
            expect(answer.change_path).to match('applications/12345/steps/circumstances/pre-cifc-reference-number')
            expect(answer.value).to eq('123456')
          end
        end

        context 'with USN' do
          let(:pre_cifc_reference_number) { 'pre_cifc_usn' }
          let(:pre_cifc_usn) { '98765' }

          it 'has the correct rows' do
            expect(answers.count).to eq(4)

            answer = answers[3]
            expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
            expect(answer.question).to eq(:pre_cifc_maat_id_or_usn)
            expect(answer.change_path).to match('applications/12345/steps/circumstances/pre-cifc-reference-number')
            expect(answer.value).to eq('98765')
          end
        end
      end
    end
  end
end
