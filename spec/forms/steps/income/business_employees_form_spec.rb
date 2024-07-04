require 'rails_helper'

RSpec.describe Steps::Income::BusinessEmployeesForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) { { crime_application:, record: }.merge(attributes) }
  let(:crime_application) { instance_double(CrimeApplication) }
  let(:record) { instance_double(Business) }
  let(:attributes) { {} }

  describe 'validations' do
    it { is_expected.to validate_is_a(:has_employees, YesNoAnswer) }
    it { is_expected.not_to validate_presence_of(:number_of_employees) }

    context 'has additional owners' do
      before { form.has_employees = 'yes' }

      it { is_expected.to validate_presence_of(:number_of_employees, :not_a_number) }
    end
  end
end
