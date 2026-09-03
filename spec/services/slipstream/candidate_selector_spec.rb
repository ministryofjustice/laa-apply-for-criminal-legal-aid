require 'rails_helper'

RSpec.describe Slipstream::CandidateSelector do
  subject(:selection) { described_class.new(crime_application, sample_rate:) }

  let(:crime_application) do
    instance_double(CrimeApplication, case: kase)
  end

  let(:kase) { instance_double(Case, charges:) }

  # 'Assault by beating' is slipstreamable, 'Make off without making payment' is not
  let(:slipstreamable_charge) { Charge.new(offence_name: 'Assault by beating') }
  let(:non_slipstreamable_charge) { Charge.new(offence_name: 'Make off without making payment') }
  let(:unlisted_charge) { Charge.new(offence_name: 'This is a test offence') }

  let(:charges) { [slipstreamable_charge] }
  let(:sample_rate) { 10 }

  describe '#call' do
    context 'when the single offence is not slipstreamable' do
      let(:charges) { [non_slipstreamable_charge] }

      it 'returns nil and does not sample' do
        expect(selection).not_to receive(:rand)
        expect(selection.call).to be_nil
      end
    end

    context 'when the single offence is unlisted' do
      let(:charges) { [unlisted_charge] }

      it { expect(selection.call).to be_nil }
    end

    context 'when there is more than one charge' do
      context 'and one of them is slipstreamable' do
        let(:charges) { [slipstreamable_charge, non_slipstreamable_charge] }

        it 'returns nil and does not sample' do
          expect(selection).not_to receive(:rand)
          expect(selection.call).to be_nil
        end
      end

      context 'and all of them are slipstreamable' do
        let(:charges) { [slipstreamable_charge, Charge.new(offence_name: 'Assault by beating')] }

        it { expect(selection.call).to be_nil }
      end
    end

    context 'when the application has no charges' do
      let(:charges) { [] }

      it { expect(selection.call).to be_nil }
    end

    context 'when there is no case' do
      let(:kase) { nil }

      it { expect(selection.call).to be_nil }
    end

    context 'when the application has a single slipstreamable offence only' do
      let(:charges) { [slipstreamable_charge] }

      context 'and it falls within the sample' do
        before { allow(selection).to receive(:rand).with(100).and_return(9) }

        it { expect(selection.call).to be(:selected) }
      end

      context 'and it falls outside the sample' do
        before { allow(selection).to receive(:rand).with(100).and_return(10) }

        it { expect(selection.call).to be(:not_selected) }
      end

      context 'when the sample rate is lower' do
        let(:sample_rate) { 5 }

        it 'uses the rate passed by the caller' do
          allow(selection).to receive(:rand).with(100).and_return(4)

          expect(selection.call).to be(:selected)
        end
      end
    end
  end
end
