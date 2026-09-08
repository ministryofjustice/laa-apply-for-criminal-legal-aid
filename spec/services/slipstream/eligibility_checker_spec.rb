require 'rails_helper'

RSpec.describe Slipstream::EligibilityChecker do
  subject(:checker) { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication, case: kase) }
  let(:kase) { instance_double(Case, charges:) }

  # 'Assault by beating' is slipstreamable, 'Make off without making payment' is not
  let(:slipstreamable_charge) { Charge.new(offence_name: 'Assault by beating') }
  let(:non_slipstreamable_charge) { Charge.new(offence_name: 'Make off without making payment') }
  let(:unlisted_charge) { Charge.new(offence_name: 'This is a test offence') }

  describe '#eligible?' do
    context 'with one slipstreamable offence' do
      let(:charges) { [slipstreamable_charge] }

      it { is_expected.to be_eligible }
    end

    context 'with one non-slipstreamable offence' do
      let(:charges) { [non_slipstreamable_charge] }

      it { is_expected.not_to be_eligible }
    end

    context 'with an unlisted offence' do
      let(:charges) { [unlisted_charge] }

      it { is_expected.not_to be_eligible }
    end

    context 'with more than one offence' do
      let(:charges) { [slipstreamable_charge, non_slipstreamable_charge] }

      it { is_expected.not_to be_eligible }
    end

    context 'with more than one slipstreamable offence' do
      let(:charges) { [slipstreamable_charge, Charge.new(offence_name: 'Assault by beating')] }

      it { is_expected.not_to be_eligible }
    end

    context 'without offences' do
      let(:charges) { [] }

      it { is_expected.not_to be_eligible }
    end

    context 'without a case' do
      let(:kase) { nil }

      it { is_expected.not_to be_eligible }
    end
  end
end
