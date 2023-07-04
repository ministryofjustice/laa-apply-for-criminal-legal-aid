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

      expect(answers[0]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[0].question).to eq(:case_urn)
      expect(answers[0].change_path).to match('applications/12345/steps/case/urn')
      expect(answers[0].value).to eq('xyz')

      expect(answers[1]).to be_an_instance_of(Summary::Components::ValueAnswer)
      expect(answers[1].question).to eq(:case_type)
      expect(answers[1].change_path).to match('applications/12345/steps/case/case_type')
      expect(answers[1].value).to eq('foobar')
    end

    context 'for appeal to crown court' do
      let(:appeal_lodged_date) { Date.new(2018, 11, 22) }

      context 'with previous MAAT ID' do
        let(:appeal_maat_id) { '123' }

        it 'has the correct rows' do
          expect(answers.count).to eq(4)

          expect(answers[2]).to be_an_instance_of(Summary::Components::DateAnswer)
          expect(answers[2].question).to eq(:appeal_lodged_date)
          expect(answers[2].change_path).to match('applications/12345/steps/case/appeal_details')
          expect(answers[2].value).to eq(appeal_lodged_date)

          expect(answers[3]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answers[3].question).to eq(:previous_maat_id)
          expect(answers[3].change_path).to match('applications/12345/steps/case/appeal_details')
          expect(answers[3].value).to eq('123')
        end
      end

      context 'without previous MAAT ID (field is optional)' do
        let(:appeal_maat_id) { '' }

        it 'has the correct rows' do
          expect(answers.count).to eq(4)

          expect(answers[3]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answers[3].question).to eq(:previous_maat_id)
          expect(answers[3].change_path).to match('applications/12345/steps/case/appeal_details')
          expect(answers[3].value).to eq('')
          expect(answers[3].show).to be(true)
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

          expect(answers[2]).to be_an_instance_of(Summary::Components::DateAnswer)
          expect(answers[2].question).to eq(:appeal_lodged_date)
          expect(answers[2].change_path).to match('applications/12345/steps/case/appeal_details')
          expect(answers[2].value).to eq(appeal_lodged_date)

          expect(answers[3]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answers[3].question).to eq(:appeal_with_changes_details)
          expect(answers[3].change_path).to match('applications/12345/steps/case/appeal_details')
          expect(answers[3].value).to eq('details')

          expect(answers[4]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answers[4].question).to eq(:previous_maat_id)
          expect(answers[4].change_path).to match('applications/12345/steps/case/appeal_details')
          expect(answers[4].value).to eq('123')
        end
      end

      context 'without previous MAAT ID (field is optional)' do
        let(:appeal_maat_id) { '' }

        it 'has the correct rows' do
          expect(answers.count).to eq(5)

          expect(answers[4]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answers[4].question).to eq(:previous_maat_id)
          expect(answers[4].change_path).to match('applications/12345/steps/case/appeal_details')
          expect(answers[4].value).to eq('')
          expect(answers[4].show).to be(true)
        end
      end
    end
  end
end
