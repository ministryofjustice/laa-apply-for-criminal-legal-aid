require 'rails_helper'

RSpec.describe Steps::Income::Client::EmployerDetailsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: employment,
      employer_name: employer_name,
      address: address_attributes,
    }
  end

  let(:crime_application) { CrimeApplication.new }
  let(:employment) { Employment.new(crime_application:) }
  let(:employer_name) { nil }

  let(:address_attributes) do
    {
      address_line_one: '10 ABC',
      address_line_two: 'XYZ Lane',
      city: 'london',
      country: 'UK',
      postcode: 'E19'
    }
  end

  describe '#save' do
    context 'when valid attributes are provided' do
      let(:employer_name) { 'abc' }

      it 'returns true' do
        expect(form.save).to be(true)
      end
    end

    context 'when `employer_name` is not provided' do
      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:employer_name, :blank)).to be(true)
      end
    end

    context 'when complete address is not provided' do
      let(:employer_name) { 'abc' }

      before {
        address_attributes.merge!(address_line_one: nil)
      }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:address_line_one, :blank)).to be(true)
      end
    end
  end
end
