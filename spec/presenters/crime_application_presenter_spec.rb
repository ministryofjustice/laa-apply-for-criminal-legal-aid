require 'rails_helper'

RSpec.describe CrimeApplicationPresenter do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.new(
      id: 'a1234bcd-5dfb-4180-ae5e-91b0fbef468d',
      created_at: DateTime.new(2022, 1, 12),
    )
  end

  let(:applicant) do
    double(
      Applicant,
      first_name: 'John',
      last_name: 'Doe',
      date_of_birth: Date.new(1990, 2, 1)
    )
  end

  let(:case_double) { instance_double(Case, case_type:) }
  let(:case_type) { nil }

  before do
    allow(crime_application).to receive(:applicant).and_return(applicant)
    allow(crime_application).to receive(:case).and_return(case_double)
  end

  describe '#interim_date_stamp' do
    context 'when a case is date stampable' do
      let(:case_type) { CaseType::SUMMARY_ONLY.to_s }

      before do
        allow(subject).to receive(:date_stamp).and_return(date_stamp)
      end

      context 'and it has a date_stamp' do
        let(:date_stamp) { DateTime.new(2022, 2, 1) }

        it { expect(subject.interim_date_stamp).to eq('1 February 2022 12:00am') }
      end

      context 'and it does not have yet a date_stamp' do
        let(:date_stamp) { nil }

        it { expect(subject.interim_date_stamp).to be_nil }
      end
    end

    context 'when a case is not date stampable' do
      let(:case_type) { CaseType::INDICTABLE.to_s }

      context 'and the application is submitted' do
        let(:crime_application) do
          CrimeApplication.new(status: :submitted, submitted_at: DateTime.new(2022, 2, 15))
        end

        it 'uses the `submitted_at` date as the date stamp' do
          expect(subject.interim_date_stamp).to eq('15 February 2022 12:00am')
        end
      end

      context 'and the application is not yet submitted' do
        it 'returns nil' do
          expect(subject.interim_date_stamp).to be_nil
        end
      end
    end
  end

  describe '#applicant?' do
    context 'when there is an applicant record' do
      it { expect(subject.applicant?).to be(true) }
    end

    context 'when there is no applicant record' do
      let(:applicant) { nil }

      it { expect(subject.applicant?).to be(false) }
    end
  end

  describe 'when presenting CrimeApplications' do
    it 'delegates full name to applicant' do
      expect(applicant).to receive(:first_name)
      expect(applicant).to receive(:last_name)
      expect(subject.applicant_name).to eq('John Doe')
    end

    it 'can output the applicant date of birth in the correct format' do
      expect(subject.applicant_dob).to eq('1 Feb 1990')
    end

    it 'can output the subject start date in the correct format' do
      expect(subject.start_date).to eq('12 Jan 2022')
    end

    it 'has an LAA an reference stubbed' do
      expect(subject.laa_reference).to eq('LAA-a1234b')
    end

    describe 'status tags' do
      it 'can output an in progress tag' do
        tag = '<strong class="govuk-tag govuk-tag--blue">In progress</strong>'
        expect(subject.status_tag).to eq(tag)
      end

      it 'can output an in submitted tag' do
        allow(subject).to receive(:status).and_return('submitted')
        tag = '<strong class="govuk-tag govuk-tag--green">Submitted</strong>'

        expect(subject.status_tag).to eq(tag)
      end
    end
  end
end
