require 'rails_helper'

RSpec.describe Steps::Partner::DetailsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      record:,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, partner: record) }
  let(:partner) {
    instance_double(Applicant, home_address:, relationship_to_owner_of_usual_home_address:, residence_type:)
  }

  describe 'validations' do
  end

  describe '#save' do
  end
end
