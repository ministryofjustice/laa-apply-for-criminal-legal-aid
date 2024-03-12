require 'rails_helper'

RSpec.describe Steps::Capital::HasNationalSavingsCertificatesForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:existing_certificates) { [] }

  it { is_expected.to validate_is_a(:has_national_savings_certificates, YesNoAnswer) }

  describe '#save' do
    let(:new_certificate) { instance_double(NationalSavingsCertificate) }
    let(:existing_certificate) { instance_double(NationalSavingsCertificate, complete?: complete?) }
    let(:complete?) { false }

    before do
      allow(crime_application).to receive(:national_savings_certificates).and_return(existing_certificates)
    end

    context 'when client has no National Savings Certificates' do
      before do
        form.has_national_savings_certificates = 'no'
      end

      it 'returns true but does not set or create a certificate' do
        expect(form.save).to be true
        expect(form.national_savings_certificate).to be_nil
      end
    end

    context 'when client has National Savings Certificates' do
      before do
        allow(NationalSavingsCertificate).to receive(:create!).with(crime_application:).and_return(new_certificate)
        form.has_national_savings_certificates = 'yes'
        form.save
      end

      context 'when there are no existing certificate records' do
        it 'a new certificate record is created' do
          expect(form.national_savings_certificate).to be new_certificate
        end
      end

      context 'when a certificate record exists' do
        let(:existing_certificates) { [existing_certificate] }

        it 'is set as the certificate record' do
          expect(form.national_savings_certificate).to be existing_certificate
        end

        context 'when the existing certificate record is complete' do
          let(:complete?) { true }

          it 'a new certificate record is created' do
            expect(form.national_savings_certificate).to be new_certificate
          end
        end
      end
    end
  end
end
