require 'rails_helper'

RSpec.describe Steps::Income::BusinessEmployeesForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) { { crime_application:, record: }.merge(attributes) }
  let(:crime_application) { instance_double(CrimeApplication) }
  let(:record) { Business.new }
  let(:attributes) { {} }

  it_behaves_like 'a form with a from_subject'

  describe 'validations' do
    it { is_expected.to validate_is_a(:has_employees, YesNoAnswer) }
    it { is_expected.not_to validate_presence_of(:number_of_employees) }

    context 'has additional owners' do
      before { form.has_employees = 'yes' }

      it { is_expected.to validate_presence_of(:number_of_employees, :not_a_number) }
    end
  end

  describe '#save' do
    context 'when valid' do
      let(:attributes) { { has_employees: 'no' } }

      it 'updates the record' do
        expect(record).to receive(:update).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when invalid' do
      let(:attributes) { { has_employees: 'yes' } }

      it 'does not update record' do
        expect(record).not_to receive(:update)
        expect(subject.save).to be(false)
      end
    end
  end
end
