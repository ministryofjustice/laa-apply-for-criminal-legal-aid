require 'rails_helper'

RSpec.describe Slipstream::CandidateSelector do
  subject(:selection) { described_class.new(crime_application, sample_rate:) }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:eligibility_checker) { instance_double(Slipstream::EligibilityChecker, eligible?: eligible) }
  let(:eligible) { true }
  let(:sample_rate) { 10 }

  before do
    allow(Slipstream::EligibilityChecker).to receive(:new)
      .with(crime_application)
      .and_return(eligibility_checker)
  end

  describe '#call' do
    context 'when the application is ineligible' do
      let(:eligible) { false }

      it 'returns nil without sampling' do
        expect(selection).not_to receive(:rand)

        expect(selection.call).to be_nil
      end
    end

    context 'when the application is eligible' do
      context 'and the random number falls within the sample rate' do
        before { allow(selection).to receive(:rand).with(100).and_return(9) }

        it { expect(selection.call).to be(:selected) }
      end

      context 'and the random number falls outside the sample rate' do
        before { allow(selection).to receive(:rand).with(100).and_return(10) }

        it { expect(selection.call).to be(:not_selected) }
      end

      context 'when given a lower sample rate' do
        let(:sample_rate) { 5 }

        it 'uses the rate passed by the caller' do
          allow(selection).to receive(:rand).with(100).and_return(4)

          expect(selection.call).to be(:selected)
        end
      end
    end
  end
end
