require 'rails_helper'

RSpec.describe Case, type: :model do
  subject { described_class.new(attributes) }

  let(:attributes) { {} }

  describe '`charges` relationship' do
    subject(:charges) do
      described_class.create(
        crime_application:
      ).charges
    end

    let(:crime_application) { CrimeApplication.create }

    it 'initialises a blank `offence_date` when building charges' do
      expect(
        charges.build.offence_dates
      ).to contain_exactly(kind_of(OffenceDate))
    end

    it 'initialises a blank `offence_date` when adding charges' do
      expect do
        charges << Charge.new
      end.to change(OffenceDate, :count).by(1)
    end

    it 'initialises a blank `offence_date` when creating charges' do
      expect do
        charges.create
      end.to change(OffenceDate, :count).by(1)
    end
  end
end
