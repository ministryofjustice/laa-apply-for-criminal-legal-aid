require 'rails_helper'

RSpec.describe Steps::Client::RelationshipStatusForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      record:,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, applicant: record) }
  let(:record) {
    instance_double(Applicant, home_address:, relationship_to_owner_of_usual_home_address:, residence_type:)
  }

  describe 'validations' do
  end

  describe '#save' do
  end
end
