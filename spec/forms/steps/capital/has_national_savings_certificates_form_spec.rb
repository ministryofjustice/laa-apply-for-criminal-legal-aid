require 'rails_helper'

RSpec.describe Steps::Capital::HasNationalSavingsCertificatesForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication, capital:) }
  let(:capital) { instance_double(Capital) }

  describe 'validations' do
    it { is_expected.to validate_is_a(:has_national_savings_certificates, YesNoAnswer) }
  end

  describe '#save' do
    context 'for valid details' do
      before do
        allow(capital).to receive(:update).and_return(true)

        form.has_national_savings_certificates = has_national_savings_certificates

        subject.save
      end

      context 'when has national savings certificates answered yes' do
        let(:has_national_savings_certificates) { 'yes' }

        let(:expected_args) do
          {
            has_national_savings_certificates: YesNoAnswer::YES
          }
        end

        it 'updates capital' do
          expect(capital).to have_received(:update).with(expected_args.stringify_keys)
        end
      end

      context 'when has national savings certificates answered no' do
        let(:has_national_savings_certificates) { 'no' }

        let(:expected_args) do
          {
            has_national_savings_certificates: YesNoAnswer::NO
          }.stringify_keys
        end

        it 'updates captial' do
          expect(capital).to have_received(:update).with(expected_args)
        end
      end
    end
  end
end
