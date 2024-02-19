require 'rails_helper'

RSpec.describe Steps::Capital::SavingsForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: saving_record
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:saving_record) { Saving.new }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:provider_name) }
  end
end
