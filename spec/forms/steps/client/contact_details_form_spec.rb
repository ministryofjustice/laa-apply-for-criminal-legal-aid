require 'rails_helper'

RSpec.describe Steps::Client::ContactDetailsForm do
  let(:arguments) { {
    crime_application: crime_application,
    telephone_number: telephone_number,
    correspondence_address_type: correspondence_address_type
  } }

  let(:crime_application) { instance_double(CrimeApplication) }

  let(:telephone_number) { nil }
  let(:correspondence_address_type) { nil }

  subject { described_class.new(arguments) }

  describe '#save' do
    context 'when telephone_number is blank' do
      let(:telephone_number) { '' }
      let(:correspondence_address_type) { 'home_address' }

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:telephone_number, :blank)).to eq(true)
      end
    end

    context 'when telephone_number contains letters' do
      let(:telephone_number) { 'not a telephone_number' }
      let(:correspondence_address_type) { 'home_address' }

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:telephone_number, :invalid)).to eq(true)
      end
    end

    context 'when telephone_number is valid' do
      let(:telephone_number) { '07000 000 000' }
      let(:correspondence_address_type) { 'home_address' }

      it 'removes spaces from input' do
        expect(subject.telephone_number).to eq('07000000000')
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :applicant,
                      expected_attributes: {
                        'telephone_number' => "07000000000",
                        'correspondence_address_type' => 'home_address'
                      }
    end

    context 'when correspondence_address_type is blank' do
      let(:telephone_number) { '07000 000 000' }

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:correspondence_address_type, :blank)).to eq(true)
      end
    end

    context 'when correspondence_address_type contains an incorrect value' do
      let(:telephone_number) { '07000 000 000' }
      let(:telephone_number) { 'university_address' }

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:correspondence_address_type, :inclusion)).to eq(true)
      end
    end
  end
end
