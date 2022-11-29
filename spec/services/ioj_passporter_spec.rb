require 'rails_helper'

RSpec.describe IojPassporter do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication, applicant:) }
  let(:applicant) { instance_double(Applicant, date_of_birth: applicant_dob) }
  let(:applicant_dob) { nil }

  before do
    allow(crime_application).to receive(:update)
    allow(crime_application).to receive(:ioj_passport).and_return([])
  end

  describe '#call' do
    context 'when applicant is over 18' do
      let(:applicant_dob) { 19.years.ago }

      it 'does not add a passported type to the array' do
        expect(crime_application).to receive(:update).with({ ioj_passport: [] })
        subject.call
      end
    end

    context 'when applicant is under 18' do
      let(:applicant_dob) { 17.years.ago }

      it 'adds a passported type to the array' do
        expect(crime_application).to receive(:update).with({ ioj_passport: [IojPassportType::ON_AGE_UNDER18.to_s] })
        subject.call
      end
    end
  end
end
