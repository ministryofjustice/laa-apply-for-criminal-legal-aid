require 'rails_helper'

RSpec.describe Steps::Income::BusinessAdditionalOwnersForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) { { crime_application:, record: }.merge(attributes) }
  let(:crime_application) { instance_double(CrimeApplication) }
  let(:record) { instance_double(Business) }
  let(:attributes) { {} }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:has_additional_owners, :inclusion) }
    it { is_expected.not_to validate_presence_of(:additional_owners) }

    context 'has additional owners' do
      before { form.has_additional_owners = 'yes' }

      it { is_expected.to validate_presence_of(:additional_owners) }
    end
  end
end
