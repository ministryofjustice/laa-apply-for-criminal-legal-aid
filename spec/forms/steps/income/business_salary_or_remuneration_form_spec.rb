require 'rails_helper'

RSpec.describe Steps::Income::BusinessSalaryOrRemunerationForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) { { crime_application:, record: }.merge(attributes) }
  let(:crime_application) { instance_double(CrimeApplication) }
  let(:record) { Business.new }
  let(:attributes) { {} }

  it_behaves_like 'a form with a from_subject'

  describe '#save' do
    let(:attributes) { { salary: { amount: '120.01', frequency: 'annual' } } }

    context 'when `salary` is valid' do
      it 'updates the record' do
        expect(record).to receive(:update).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when `salary` is invalid' do
      let(:attributes) { { salary: { amount: nil, frequency: 'annual' } } }

      it 'does not update record' do
        expect(record).not_to receive(:update)
        expect(subject.save).to be(false)
      end

      it 'adds an error' do
        subject.save
        expect(form.errors.added?(:salary, :amount_blank)).to be true
      end
    end
  end
end