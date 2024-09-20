require 'rails_helper'

RSpec.describe DateStamper do
  subject { described_class.new(crime_app, case_type:) }

  let(:crime_app) do
    instance_double(
      CrimeApplication,
      date_stamp: date,
      applicant: applicant,
    )
  end

  let(:not_means_tested) { nil }

  let(:applicant) do
    instance_double(
      Applicant,
      first_name: 'Jason',
      last_name: 'Apple',
      other_names: 'Bruno',
      date_of_birth: '1990-01-01',
    )
  end

  before do
    allow(crime_app).to receive_messages(save: true, not_means_tested?: not_means_tested)
  end

  describe '#call' do
    context 'when application is not means tested' do
      let(:not_means_tested) { true }
      let(:case_type) { nil }
      let(:date) { nil }

      it 'adds a date stamp and context to the crime app' do
        expect(crime_app).to receive(:date_stamp=).with(instance_of(ActiveSupport::TimeWithZone))
        expect(crime_app).to receive(:date_stamp_context=).with(instance_of(DateStampContext))

        subject.call
      end
    end

    context 'when case_type is "date stampable" and date_stamp is nil' do
      let(:not_means_tested) { false }

      let(:case_type) { CaseType::DATE_STAMPABLE.sample }
      let(:date) { nil }

      it 'adds a date stamp to the crime app' do
        expect(crime_app).to receive(:date_stamp=).with(instance_of(ActiveSupport::TimeWithZone))
        expect(crime_app).to receive(:date_stamp_context=).with(instance_of(DateStampContext))

        subject.call
      end
    end

    context 'when case_type is "date stampable" and has already been date stamped' do
      let(:not_means_tested) { false }

      let(:case_type) { CaseType::DATE_STAMPABLE.sample }
      let(:date) { DateTime.new(2022, 2, 2) }

      it 'does not update the crime applications a date stamp' do
        expect(crime_app).not_to receive(:date_stamp=)
        expect(crime_app).not_to receive(:date_stamp_context=)

        result = subject.call

        expect(result).to be(false)
      end
    end

    context 'when case_type is not "date stampable"' do
      let(:not_means_tested) { false }

      let(:case_type) { CaseType::INDICTABLE }
      let(:date) { nil }

      it 'does not update the crime applications a date stamp' do
        expect(crime_app).not_to receive(:date_stamp=)
        expect(crime_app).not_to receive(:date_stamp_context=)

        result = subject.call

        expect(result).to be(false)
      end
    end
  end
end
