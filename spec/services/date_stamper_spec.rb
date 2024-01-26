require 'rails_helper'

RSpec.describe DateStamper do
  subject { described_class.new(crime_app, case_type:) }

  let(:crime_app) do
    instance_double(
      CrimeApplication,
      date_stamp: date
    )
  end

  let(:not_means_tested) { nil }

  before do
    allow(crime_app).to receive(:update)
    allow(crime_app).to receive(:not_means_tested?).and_return(not_means_tested)
  end

  describe '#call' do
    context 'when application is not means tested' do
      let(:not_means_tested) { true }
      let(:case_type) { nil }
      let(:date) { nil }

      it 'adds a date stamp to the crime app' do
        expect(crime_app).to receive(:update).with({ date_stamp: instance_of(ActiveSupport::TimeWithZone) })
        subject.call
      end
    end

    context 'when case_type is "date stampable" and date_stamp is nil' do
      let(:not_means_tested) { false }

      let(:case_type) { CaseType::DATE_STAMPABLE.sample }
      let(:date) { nil }

      it 'adds a date stamp to the crime app' do
        expect(crime_app).to receive(:update).with({ date_stamp: instance_of(ActiveSupport::TimeWithZone) })
        subject.call
      end
    end

    context 'when case_type is "date stampable" and has already been date stamped' do
      let(:not_means_tested) { false }

      let(:case_type) { CaseType::DATE_STAMPABLE.sample }
      let(:date) { DateTime.new(2022, 2, 2) }

      it 'does not update the crime applications a date stamp' do
        expect(crime_app).not_to receive(:update)

        result = subject.call

        expect(result).to be(false)
      end
    end

    context 'when case_type is not "date stampable"' do
      let(:not_means_tested) { false }

      let(:case_type) { CaseType::INDICTABLE }
      let(:date) { nil }

      it 'does not update the crime applications a date stamp' do
        expect(crime_app).not_to receive(:update)

        result = subject.call

        expect(result).to be(false)
      end
    end
  end
end
