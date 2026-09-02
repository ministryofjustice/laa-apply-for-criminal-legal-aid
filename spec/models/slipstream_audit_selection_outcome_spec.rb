require 'rails_helper'

RSpec.describe SlipstreamAuditSelectionOutcome, type: :model do
  subject(:outcome) do
    described_class.create!(
      crime_application: crime_application,
      sampled_at: sampled_at,
      status: :selected,
      status_determined_at: sampled_at,
      sample_rate: 10
    )
  end

  let(:crime_application) { CrimeApplication.create! }
  let(:sampled_at) { Time.current }

  describe 'associations' do
    it { expect(outcome.crime_application).to eq(crime_application) }

    it 'is destroyed with its crime application' do
      outcome
      expect { crime_application.destroy! }.to change(described_class, :count).from(1).to(0)
    end
  end

  describe 'status' do
    it { expect(outcome.selected?).to be true }
  end

  describe 'validations' do
    it 'requires a sample rate greater than zero' do
      outcome.sample_rate = 0

      expect(outcome).not_to be_valid
    end

    it 'requires a sample rate no greater than 100' do
      outcome.sample_rate = 101

      expect(outcome).not_to be_valid
    end

    it 'requires sampled_at' do
      outcome.sampled_at = nil

      expect(outcome).not_to be_valid
    end

    it 'requires status_determined_at' do
      outcome.status_determined_at = nil

      expect(outcome).not_to be_valid
    end
  end
end
