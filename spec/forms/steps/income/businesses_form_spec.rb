require 'rails_helper'

RSpec.describe Steps::Income::BusinessesForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) { { crime_application:, record: }.merge(attributes) }
  let(:crime_application) { instance_double(CrimeApplication) }
  let(:record) { Business.new }
  let(:attributes) {{}}

  let(:valid_attributes) do
    {
      trading_name: 'Foo Bar LTD',
      address_line_one: '1 Line ST ',
      city: 'Lincoln ',
      postcode: 'LN1 1LN',
      country: 'UK'
    }
  end

  it_behaves_like 'a form with a from_subject'
  
  describe '#validations' do
    it { is_expected.to validate_presence_of(:address_line_one) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:postcode) }
    it { is_expected.to validate_presence_of(:country) }
    it { is_expected.to validate_presence_of(:trading_name) }
    it { is_expected.not_to validate_presence_of(:address_line_two) }
  end

  describe '#save' do
    context 'when valid' do
      let(:attributes) { valid_attributes }

      it 'updates the record' do
        expect(record).to receive(:update).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when invalid' do
      let(:attributes) { valid_attributes.merge(trading_name: nil) }

      it 'does not update record' do
        expect(record).not_to receive(:update)
        expect(subject.save).to be(false)
      end
    end
  end
end
