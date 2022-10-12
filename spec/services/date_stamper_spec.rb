require 'rails_helper'

RSpec.describe DateStamper do
  subject { described_class.new(crime_app, case_type) }

  let(:crime_app) do
    instance_double(
      CrimeApplication,
      date_stamp: date
    )
  end

  before do
    allow(crime_app).to receive(:update)
  end

  describe '#call' do
    context 'when case_type is "date stampable" and date_stamp is nil' do
      let(:case_type) { CaseType::DATE_STAMPABLE.sample }
      let(:date) { nil }

      it 'adds a date stamp to the crime app' do
        expect(crime_app).to receive(:update).with({ date_stamp: instance_of(DateTime) })
        subject.call
      end
    end

    context 'when case_type is "date stampable" and has already been date stamped' do
      let(:case_type) { CaseType::DATE_STAMPABLE.sample }
      let(:date) { DateTime.new(2022, 2, 2) }

      it 'does not update the crime applications a date stamp' do
        expect(crime_app).not_to receive(:update)

        result = subject.call

        expect(result).to be(false)
      end
    end

    context 'when case_type is not "date stampable"' do
      let(:case_type) { CaseType::CC_APPEAL_FIN_CHANGE }
      let(:date) { nil }

      it 'does not update the crime applications a date stamp' do
        expect(crime_app).not_to receive(:update)

        result = subject.call

        expect(result).to be(false)
      end
    end
  end
end
