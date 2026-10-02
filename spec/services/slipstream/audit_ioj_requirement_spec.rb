require 'rails_helper'

RSpec.describe Slipstream::AuditIojRequirement do
  subject(:requirement) { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication, slipstream_audit_selection_outcome: outcome) }
  let(:outcome) do
    instance_double(
      SlipstreamAuditSelectionOutcome,
      selected?: selected,
      confirmed?: confirmed,
      selection_reason: selection_reason
    )
  end
  let(:selected) { true }
  let(:confirmed) { false }
  let(:selection_reason) { 'offence' }
  let(:eligible_for_offence) { true }
  let(:normally_passported) { true }
  let(:checker) do
    instance_double(Slipstream::EligibilityChecker,
                    eligible?: eligible_for_offence,
                    single_slipstreamable_offence?: eligible_for_offence)
  end
  let(:feature_enabled) { true }

  before do
    allow(FeatureFlags).to receive(:slipstream_audit)
      .and_return(instance_double(FeatureFlags::EnabledFeature, enabled?: feature_enabled))
    allow(Slipstream::EligibilityChecker).to receive(:new).with(crime_application).and_return(checker)
  end

  it { expect(requirement.required?(normally_passported:)).to be(true) }

  context 'when the feature flag is disabled' do
    let(:feature_enabled) { false }

    it { expect(requirement.required?(normally_passported:)).to be(false) }
  end

  context 'when the outcome is not selected or confirmed' do
    let(:selected) { false }

    it { expect(requirement.required?(normally_passported:)).to be(false) }
  end

  context 'when the offence selection no longer qualifies after charges change' do
    let(:eligible_for_offence) { false }

    it { expect(requirement.required?(normally_passported:)).to be(false) }
  end

  context 'when an active outcome has no recorded reason' do
    let(:selection_reason) { nil }

    it 'falls back to current eligibility' do
      expect(requirement.required?(normally_passported:)).to be(true)
    end
  end

  context 'when an age-selected applicant ages out' do
    let(:selection_reason) { 'age' }
    let(:eligible_for_offence) { false }

    it { expect(requirement.required?(normally_passported:)).to be(true) }
  end

  context 'when IoJ is already required independently of the audit' do
    let(:normally_passported) { false }

    it { expect(requirement.required?(normally_passported:)).to be(false) }
  end

  context 'when an outcome is confirmed after return' do
    let(:selected) { false }
    let(:confirmed) { true }

    it { expect(requirement.required?(normally_passported:)).to be(true) }
  end
end
