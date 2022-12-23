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
  let(:provider_record) { Provider.new(rep_details_attrs) }
  let(:crime_application) { instance_double(CrimeApplication) }

  let(:rep_details_attrs) { {} }

  describe '#save' do
    context 'validations' do
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

    context 'when validations pass' do
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
            expected_attrs
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

        it 'does not save the record but returns true' do
          expect(crime_application).not_to receive(:update)
          expect(provider_record).not_to receive(:update)
          expect(subject.save).to be(true)
        end
      end
    end
  end
end
