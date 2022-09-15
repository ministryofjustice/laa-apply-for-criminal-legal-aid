require 'rails_helper'

RSpec.describe Case, type: :model do
  subject { described_class.new(attributes) }
  let(:attributes) { {} }

  describe '`charges` relationship' do
    let(:crime_application) { CrimeApplication.create }

    subject(:charges) {
      described_class.create(
        crime_application: crime_application
      ).charges
    }

    it 'initialises a blank `offence_date` when building charges' do
      expect(
        charges.build.offence_dates
      ).to contain_exactly(kind_of(OffenceDate))
    end

    it 'initialises a blank `offence_date` when adding charges' do
      expect {
        charges << Charge.new
      }.to change { OffenceDate.count }.by(1)
    end

    it 'initialises a blank `offence_date` when creating charges' do
      expect {
        charges.create
      }.to change { OffenceDate.count }.by(1)
    end
  end
end
