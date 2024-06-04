require 'rails_helper'

RSpec.describe Steps::Capital::HasNationalSavingsCertificatesForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication, capital:) }
  let(:capital) { instance_double(Capital, has_national_savings_certificates:) }
  let(:has_national_savings_certificates) { YesNoAnswer::YES }
  let(:existing_certificates) { [] }

  describe '#validations' do
    before do
      allow(form).to receive(:include_partner_in_means_assessment?) { include_partner? }
      form.has_national_savings_certificates = nil
    end

    let(:include_partner?) { false }
    let(:error_message) { 'Select yes if your client has any National Savings Certificates' }

    it { is_expected.to validate_presence_of(:has_national_savings_certificates, :blank, error_message) }

    context 'when partner is included in means assessment' do
      let(:include_partner?) { true }

      let(:error_message) do
        'Select yes if your client or their partner has any National Savings Certificates'
      end

      it { is_expected.to validate_presence_of(:has_national_savings_certificates, :blank, error_message) }
    end
  end

  describe '#save' do
    let(:new_certificate) { instance_double(NationalSavingsCertificate) }
    let(:existing_certificate) { instance_double(NationalSavingsCertificate, complete?: complete?) }
    let(:complete?) { false }

    before do
      allow(crime_application).to receive(:national_savings_certificates).and_return(existing_certificates)
      allow(capital).to receive(:update).with(has_national_savings_certificates:).and_return(true)
    end

    context 'when client has no National Savings Certificates' do
      let(:has_national_savings_certificates) { YesNoAnswer::NO }

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
