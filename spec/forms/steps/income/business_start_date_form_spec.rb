require 'rails_helper'

RSpec.describe Steps::Income::BusinessStartDateForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) { { crime_application:, record: }.merge(attributes) }
  let(:crime_application) { instance_double(CrimeApplication) }
  let(:record) { Business.new }
  let(:attributes) { {} }

  it_behaves_like 'a form with a from_subject'

  describe '#validations' do
    it { is_expected.to validate_presence_of(:trading_start_date) }

    it_behaves_like('a multiparam date validation',
                    attribute_name: :trading_start_date, earliest_year: 1000)
  end

  describe '#save' do
    context 'when valid' do
      let(:attributes) { { trading_start_date: Date.new(2020, 7, 2) } }

      it 'updates the record' do
        expect(record).to receive(:update).and_return(true)
        expect(subject.save).to be(true)
      end
    end

    context 'when invalid' do
      let(:attributes) { { trading_start_date: '' } }

      it 'does not update record' do
        expect(record).not_to receive(:update)
        expect(subject.save).to be(false)
      end
    end
  end
end
