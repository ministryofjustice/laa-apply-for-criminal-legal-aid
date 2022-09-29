require 'rails_helper'

RSpec.describe DateStamper do
  let(:case_type_sym) { described_class::DATE_STAMPABLE.sample }
  let(:date) { DateTime.new(2022, 02, 02) }
  let(:case_type) { CaseType.new(case_type_sym) }
  let(:crime_app) {
    instance_double(
      CrimeApplication,
      date_stamp: date
    )
  }

  subject { described_class.new(crime_app, case_type) }

  before do
    allow(crime_app).to receive(:update)
  end

  describe '#call' do
    context 'when case_type is "date stampable" and date_stamp is nil' do
      let(:date) { nil }

      it 'it adds a date stamp to the crime app' do
        expect(crime_app).to receive(:update).with({date_stamp: instance_of(DateTime)})
        subject.call
      end
    end

    context 'when case_type is not "date stampable"' do
      let(:case_type_sym) { :cc_appeal_fin_change }

      it 'resets the the crime applications date stamp' do
        expect(crime_app).not_to receive(:update)

        result = subject.call

        expect(result).to be(false)
      end
    end

    context 'when case_type is "date stampable" and has already been date stamped' do
      let(:case_type_sym) { :cc_appeal_fin_change }

      it 'does not update the crime applications a date stamp' do
        expect(crime_app).not_to receive(:update)

        result = subject.call

        expect(result).to be(false)
      end
    end

    context 'when case_type is not "date stampable" and has no date stamped' do
      let(:case_type_sym) { :cc_appeal_fin_change }
      let(:date) { nil }

      it 'does not update the crime applications a date stamp' do
        expect(crime_app).not_to receive(:update)

        result = subject.call

        expect(result).to be(false)
      end
    end
  end
end
