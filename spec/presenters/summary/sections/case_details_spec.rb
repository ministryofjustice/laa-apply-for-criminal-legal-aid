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
      appeal_maat_id: appeal_maat_id,
      appeal_lodged_date: appeal_lodged_date,
      appeal_with_changes_details: appeal_with_changes_details,
    )
  end

  let(:appeal_maat_id) { nil }
  let(:appeal_lodged_date) { nil }
  let(:appeal_with_changes_details) { nil }

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

    it 'has the correct rows' do
      expect(answers.count).to eq(2)

      answer = answers[0]
      expect(answer).to be_an_instance_of(Summary::Components::ValueAnswer)
      expect(answer.question).to eq(:case_type)
      expect(answer.change_path).to match('applications/12345/steps/case/case_type')
      expect(answer.value).to eq('foobar')

      answer = answers[1]
      expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answer.question).to eq(:case_urn)
      expect(answer.change_path).to match('applications/12345/steps/case/urn')
      expect(answer.value).to eq('xyz')
    end

    context 'for appeal to crown court' do
      let(:appeal_lodged_date) { Date.new(2018, 11, 22) }

      context 'with previous MAAT ID' do
        let(:appeal_maat_id) { '123' }

        it 'has the correct rows' do
          expect(answers.count).to eq(4)

          answer = answers[1]
          expect(answer).to be_an_instance_of(Summary::Components::DateAnswer)
          expect(answer.question).to eq(:appeal_lodged_date)
          expect(answer.change_path).to match('applications/12345/steps/case/appeal_details')
          expect(answer.value).to eq(appeal_lodged_date)

          answer = answers[2]
          expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answer.question).to eq(:previous_maat_id)
          expect(answer.change_path).to match('applications/12345/steps/case/appeal_details')
          expect(answer.value).to eq('123')
        end
      end

      context 'without previous MAAT ID (field is optional)' do
        let(:appeal_maat_id) { '' }

        it 'has the correct rows' do
          expect(answers.count).to eq(4)

          answer = answers[2]
          expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answer.question).to eq(:previous_maat_id)
          expect(answer.change_path).to match('applications/12345/steps/case/appeal_details')
          expect(answer.value).to eq('')
          expect(answer.show).to be(true)
        end
      end
    end

    context 'for appeal to crown court with changes in financial circumstances' do
      let(:appeal_lodged_date) { Date.new(2018, 11, 22) }
      let(:appeal_with_changes_details) { 'details' }

      context 'with previous MAAT ID' do
        let(:appeal_maat_id) { '123' }

        it 'has the correct rows' do
          expect(answers.count).to eq(5)

          answer = answers[1]
          expect(answer).to be_an_instance_of(Summary::Components::DateAnswer)
          expect(answer.question).to eq(:appeal_lodged_date)
          expect(answer.change_path).to match('applications/12345/steps/case/appeal_details')
          expect(answer.value).to eq(appeal_lodged_date)

          answer = answers[2]
          expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answer.question).to eq(:appeal_with_changes_details)
          expect(answer.change_path).to match('applications/12345/steps/case/appeal_details')
          expect(answer.value).to eq('details')

          answer = answers[3]
          expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answer.question).to eq(:previous_maat_id)
          expect(answer.change_path).to match('applications/12345/steps/case/appeal_details')
          expect(answer.value).to eq('123')
        end
      end

      context 'without previous MAAT ID (field is optional)' do
        let(:appeal_maat_id) { '' }

        it 'has the correct rows' do
          expect(answers.count).to eq(5)

          answer = answers[3]
          expect(answer).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answer.question).to eq(:previous_maat_id)
          expect(answer.change_path).to match('applications/12345/steps/case/appeal_details')
          expect(answer.value).to eq('')
          expect(answer.show).to be(true)
        end
      end
    end
  end
end
