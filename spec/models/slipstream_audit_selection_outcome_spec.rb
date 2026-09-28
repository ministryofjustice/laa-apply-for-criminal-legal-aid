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

  describe 'selection_reason' do
    it { expect(outcome.selection_reason).to be_nil }

    it 'accepts a nil selection_reason' do
      outcome.selection_reason = nil

      expect(outcome).to be_valid
    end

    it 'accepts the offence selection_reason' do
      outcome.selection_reason = :offence

      expect(outcome).to be_valid
      expect(outcome.offence?).to be true
    end

    it 'accepts the age selection_reason' do
      outcome.selection_reason = :age

      expect(outcome).to be_valid
      expect(outcome.age?).to be true
    end

    it 'rejects an unsupported selection_reason at the database level' do
      expect { outcome.update_column(:selection_reason, 'unsupported') } # rubocop:disable Rails/SkipsModelValidations
        .to raise_error(ActiveRecord::StatementInvalid, /slipstream_audit_selection_outcomes_reason_check/)
    end
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
