require 'rails_helper'

describe Summary::Sections::DateStampContext do
  let(:crime_application) do
    instance_double(
      CrimeApplication,
      applicant:,
      date_stamp_context:,
    )
  end

  let(:date_stamp_context) do
    DateStampContext.new(
      first_name: 'Danger',
      last_name: 'Mouse',
      date_of_birth: Date.new(1990, 1, 1),
      date_stamp: Time.zone.local(2024, 1, 5, 10, 12, 13),
    )
  end

  let(:applicant) do
    instance_double(
      Applicant,
      first_name: 'Danger',
      last_name: 'Mouse',
      date_of_birth: Date.new(1990, 1, 1),
    )
  end

  describe '#show?' do
    subject { described_class.new(crime_application).show? }

    context 'when no applicant date stampable details have changed' do
      it { is_expected.to be false }
    end

    context 'when first name has changed' do
      before { date_stamp_context.first_name = 'Changed first name' }

      it { is_expected.to be true }
    end

    context 'when last name has changed' do
      before { date_stamp_context.last_name = 'Changed last name' }

      it { is_expected.to be true }
    end

    context 'when date of birth has changed' do
      before { date_stamp_context.date_of_birth = Date.new(2000, 2, 2) }

      it { is_expected.to be true }
    end

    context 'when date stamp context has blank first name' do
      before do
        date_stamp_context.first_name = ''
      end

      it { is_expected.to be false }
    end

    context 'when date stamp context has blank last name' do
      before do
        date_stamp_context.last_name = ''
      end

      it { is_expected.to be false }
    end

    context 'when date stamp context has blank date of birth' do
      before do
        date_stamp_context.date_of_birth = ''
      end

      it { is_expected.to be false }
    end
  end

  describe '#answers' do
    subject(:answers) { described_class.new(crime_application).answers }

    context 'with all date stamp context attributes' do
      before do
        date_stamp_context.last_name = 'Changed first name'
        date_stamp_context.last_name = 'Changed last name'
        date_stamp_context.date_of_birth = Date.new(2001, 2, 2)
      end

      it 'has the correct rows' do
        changed_message_tag_html = [
          '<strong class="date-stamp-context__tag govuk-tag govuk-tag--red">',
          'Changed after date stamp',
          '</strong>',
        ].join

        expect(answers.count).to eq(4)

        expect(answers[0]).to be_an_instance_of(Summary::Components::DateAnswer)
        expect(answers[0].question).to eq(:date_stamp)
        expect(answers[0].change_path).to be_nil
        expect(answers[0].value).to be_a(Time)
        expect(answers[0].show).to be true
        expect(answers[0].answer_text).to eq('05/01/2024 10:12am')

        expect(answers[1]).to be_an_instance_of(Summary::Components::ChangedDateStampAnswer)
        expect(answers[1].question).to eq(:first_name)
        expect(answers[1].change_path).to be_nil
        expect(answers[1].value).to eq('Danger')
        expect(answers[1].show).to be true
        expect(answers[1].answer_text).to eq('<p>Danger</p>')

        expect(answers[2]).to be_an_instance_of(Summary::Components::ChangedDateStampAnswer)
        expect(answers[2].question).to eq(:last_name)
        expect(answers[2].change_path).to be_nil
        expect(answers[2].value).to eq('Changed last name')
        expect(answers[2].show).to be true
        expect(answers[2].answer_text).to eq("<p>Changed last name</p>#{changed_message_tag_html}")

        # Note date output is treated the same as standard string output
        expect(answers[3]).to be_an_instance_of(Summary::Components::ChangedDateStampAnswer)
        expect(answers[3].question).to eq(:date_of_birth)
        expect(answers[3].change_path).to be_nil
        expect(answers[3].value).to be_an_instance_of(Date)
        expect(answers[3].show).to be true
        expect(answers[3].answer_text).to eq("<p>2 February 2001</p>#{changed_message_tag_html}")
      end
    end

    context 'with missing date stamp context attributes' do
      before do
        date_stamp_context.first_name = nil
        date_stamp_context.last_name = nil
        date_stamp_context.date_of_birth = Date.new(2001, 2, 2)
      end

      it 'has selected rows' do
        expect(answers[0].question).to eq(:date_stamp)
        expect(answers[0].show).to be true

        expect(answers[1].question).to eq(:date_of_birth)
        expect(answers[1].show).to be true
      end
    end
  end

  describe '#editable?' do
    subject { described_class.new(crime_application).editable? }

    it { is_expected.to be false }
  end
end
