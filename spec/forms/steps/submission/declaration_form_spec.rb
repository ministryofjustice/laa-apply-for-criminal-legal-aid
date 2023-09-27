require 'rails_helper'

RSpec.describe Steps::Submission::DeclarationForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      record: provider_record,
      crime_application: crime_application,
      legal_rep_first_name: 'John',
      legal_rep_last_name: 'Doe',
      legal_rep_telephone: legal_rep_telephone,
    }
  end

  let(:legal_rep_telephone) { '123456789' }
  let(:provider_record) { Provider.new(provider_attrs.merge(rep_details_attrs)) }
  let(:crime_application) { instance_double(CrimeApplication) }

  let(:provider_attrs) { { email: 'provider@example.com' } }
  let(:rep_details_attrs) { {} }

  describe '#fulfilment_errors' do
    it 'instantiate the presenter' do
      expect(FulfilmentErrorsPresenter).to receive(:new).with(crime_application).and_call_original
      expect(crime_application).to receive(:errors).and_return([])
      expect(subject.fulfilment_errors).to eq([])
    end
  end

  describe '#save' do
    before do
      allow(crime_application).to receive(:valid?).with(:submission).and_return(fulfilment_ok)
    end

    context 'validations' do
      let(:fulfilment_ok) { true }

      it { is_expected.to validate_presence_of(:legal_rep_first_name) }
      it { is_expected.to validate_presence_of(:legal_rep_last_name) }
      it { is_expected.to validate_presence_of(:legal_rep_telephone) }

      context 'when `legal_rep_telephone` contains letters' do
        let(:legal_rep_telephone) { 'not a telephone_number' }

        it 'has a validation error on the field' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:legal_rep_telephone, :invalid)).to be(true)
        end
      end

      context 'when `legal_rep_telephone` is valid' do
        let(:legal_rep_telephone) { '(+44) 55-55.555 #22' }

        it 'removes spaces from input' do
          expect(subject.legal_rep_telephone).to eq('(+44)55-55.555#22')
        end
      end
    end

    context 'when form validations pass' do
      let(:fulfilment_ok) { true }

      let(:expected_attrs) do
        {
          'legal_rep_first_name' => 'John',
          'legal_rep_last_name' => 'Doe',
          'legal_rep_telephone' => '123456789',
        }
      end

      context 'when the details have changed' do
        it 'saves the application record' do
          allow(provider_record).to receive(:update).and_return(true)

          expect(crime_application).to receive(:update).with(
            expected_attrs.merge(provider_email: 'provider@example.com')
          ).and_return(true)

          expect(subject.save).to be(true)
        end

        it 'saves the provider settings' do
          allow(crime_application).to receive(:update).and_return(true)

          expect(provider_record).to receive(:update).with(
            expected_attrs
          ).and_return(true)

          expect(subject.save).to be(true)
        end

        context 'when saving a draft' do
          let(:legal_rep_telephone) { '' }

          it 'saves to the provider settings attributes that are not blank' do
            allow(crime_application).to receive(:update).and_return(true)

            expect(provider_record).to receive(:update).with(
              {
                'legal_rep_first_name' => 'John',
                'legal_rep_last_name' => 'Doe',
              }
            ).and_return(true)

            expect(subject.save!).to be(true)
          end
        end
      end

      context 'when the details have not changed' do
        let(:rep_details_attrs) { expected_attrs }

        it 'saves the record, but not the provider settings, and returns true' do
          expect(crime_application).to receive(:update)
          expect(provider_record).not_to receive(:update)
          expect(subject.save).to be(true)
        end
      end
    end

    context 'when application fulfilment is not successful' do
      let(:fulfilment_ok) { false }

      let(:crime_application) { instance_double(CrimeApplication, errors: crime_application_errors) }
      let(:crime_application_errors) { double('errors') }

      before do
        expect(crime_application_errors).to receive(:full_messages).and_return(%w[error1 error2])
      end

      it 'has an error in the `crime_application` attribute' do
        expect(subject.save).to be(false)
        expect(subject.errors.added?(:crime_application, :invalid)).to be(true)
      end

      it 'reports the fulfilment errors' do
        expect(Rails.error).to receive(:report).with(
          kind_of(
            Steps::Submission::DeclarationForm::ApplicationFulfilmentError
          ), hash_including(handled: true)
        )

        subject.save
      end
    end
  end
end
