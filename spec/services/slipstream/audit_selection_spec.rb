require 'rails_helper'

RSpec.describe Slipstream::AuditSelection do
  subject(:selection) { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(CrimeApplication, case: kase)
  end

  let(:kase) { instance_double(Case, charges:) }

  # 'Assault by beating' is slipstreamable, 'Make off without making payment' is not
  let(:slipstreamable_charge) { Charge.new(offence_name: 'Assault by beating') }
  let(:non_slipstreamable_charge) { Charge.new(offence_name: 'Make off without making payment') }
  let(:unlisted_charge) { Charge.new(offence_name: 'This is a test offence') }

  let(:charges) { [slipstreamable_charge] }
  let(:feature_disabled) { false }

  before do
    allow(FeatureFlags).to receive(:slipstream_audit).and_return(double(disabled?: feature_disabled))
    allow(Settings).to receive(:slipstream_audit).and_return({ sample_rate: 10 }.with_indifferent_access)
  end

  describe '#call' do
    context 'when the feature flag is disabled' do
      let(:feature_disabled) { true }

      it 'is not selected, regardless of eligibility or sampling' do
        expect(selection).not_to receive(:rand)
        expect(selection.call).to be(false)
      end
    end

    context 'when the feature flag is enabled' do
      context 'when the single offence is not slipstreamable' do
        let(:charges) { [non_slipstreamable_charge] }

        it 'is not selected and does not sample' do
          expect(selection).not_to receive(:rand)
          expect(selection.call).to be(false)
        end
      end

      context 'when the single offence is unlisted' do
        let(:charges) { [unlisted_charge] }

        it { expect(selection.call).to be(false) }
      end

      context 'when there is more than one charge' do
        context 'and one of them is slipstreamable' do
          let(:charges) { [slipstreamable_charge, non_slipstreamable_charge] }

          it 'is not selected and does not sample' do
            expect(selection).not_to receive(:rand)
            expect(selection.call).to be(false)
          end
        end

        context 'and all of them are slipstreamable' do
          let(:charges) { [slipstreamable_charge, Charge.new(offence_name: 'Assault by beating')] }

          it { expect(selection.call).to be(false) }
        end
      end

      context 'when the application has no charges' do
        let(:charges) { [] }

        it { expect(selection.call).to be(false) }
      end

      context 'when there is no case' do
        let(:kase) { nil }

        it { expect(selection.call).to be(false) }
      end

      context 'when the application has a single slipstreamable offence only' do
        let(:charges) { [slipstreamable_charge] }

        context 'and it falls within the sample' do
          before { allow(selection).to receive(:rand).with(100).and_return(9) }

          it { expect(selection.call).to be(true) }
        end

        context 'and it falls outside the sample' do
          before { allow(selection).to receive(:rand).with(100).and_return(10) }

          it { expect(selection.call).to be(false) }
        end

        it 'samples using the configured sample rate' do
          allow(Settings).to receive(:slipstream_audit).and_return({ sample_rate: 5 }.with_indifferent_access)
          allow(selection).to receive(:rand).with(100).and_return(4)

          expect(selection.call).to be(true)
        end
      end
    end
  end
end
