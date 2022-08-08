require 'rails_helper'

RSpec.describe Steps::Client::ContactDetailsForm do
  let(:arguments) { {
    crime_application: crime_application,
    telephone_number: telephone_number
  } }

  let(:crime_application) { instance_double(CrimeApplication) }

  let(:telephone_number) { nil }

  subject { described_class.new(arguments) }

  describe '#save' do
    context 'when telephone_number is blank' do
      let(:telephone_number) { '' }

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:telephone_number, :blank)).to eq(true)
      end
    end

    context 'when telephone_number contains letters' do
      let(:telephone_number) { 'not a telephone_number' }

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:telephone_number, :invalid)).to eq(true)
      end
    end

    context 'when telephone_number is valid' do
      let(:telephone_number) { '07000 000 000' }

      it 'removes spaces from input' do
        expect(subject.telephone_number).to eq('07000000000')
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :applicant,
                      expected_attributes: {
                        'telephone_number' => "07000000000"
                      }
    end
  end
end
