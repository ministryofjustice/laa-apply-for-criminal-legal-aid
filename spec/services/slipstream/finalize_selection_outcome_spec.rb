require 'rails_helper'

RSpec.describe Slipstream::FinalizeSelectionOutcome do
  subject(:finalizer) { described_class.new(crime_application) }

  let(:crime_application) { CrimeApplication.create! }
  let(:eligibility_checker) { instance_double(Slipstream::EligibilityChecker, eligible?: eligible) }
  let(:eligible) { true }
  let(:sampled_at) { Time.zone.parse('2026-09-03 10:00:00') }
  let(:initially_determined_at) { Time.zone.parse('2026-09-03 10:00:00') }
  let(:finalized_at) { Time.zone.parse('2026-09-04 11:00:00') }
  let(:status) { :selected }
  let!(:outcome) do
    crime_application.create_slipstream_audit_selection_outcome!(
      status: status,
      sample_rate: 10,
      sampled_at: sampled_at,
      status_determined_at: initially_determined_at
    )
  end

  before do
    allow(Slipstream::EligibilityChecker).to receive(:new)
      .with(crime_application)
      .and_return(eligibility_checker)
    allow(Time).to receive(:current).and_return(finalized_at)
  end

  describe '#call' do
    context 'when a selected application remains eligible' do
      it 'confirms the outcome and records when it was finalized' do
        expect(finalizer.call).to have_attributes(
          status: 'confirmed',
          status_determined_at: finalized_at
        )
      end

      it 'preserves the original sampling metadata' do
        expect { finalizer.call }.not_to(
          change { outcome.reload.attributes.values_at('sample_rate', 'sampled_at') }
        )
      end

      it 'does not finalize the outcome again' do
        expect(eligibility_checker).to receive(:eligible?).once.and_return(true)

        finalizer.call

        expect { finalizer.call }.not_to(change { outcome.reload.attributes })
      end
    end

    context 'when a selected application is no longer eligible' do
      let(:eligible) { false }

      it 'withdraws the outcome and records when it was finalized' do
        expect(finalizer.call).to have_attributes(
          status: 'withdrawn',
          status_determined_at: finalized_at
        )
      end
    end

    context 'when the outcome is not selected' do
      let(:status) { :not_selected }

      it 'leaves the outcome unchanged without checking eligibility' do
        expect(eligibility_checker).not_to receive(:eligible?)

        expect { finalizer.call }.not_to(change { outcome.reload.attributes })
      end
    end

    context 'when the outcome is already confirmed' do
      let(:status) { :confirmed }

      it 'leaves the outcome unchanged without checking eligibility' do
        expect(eligibility_checker).not_to receive(:eligible?)

        expect { finalizer.call }.not_to(change { outcome.reload.attributes })
      end
    end

    context 'when the outcome is already withdrawn' do
      let(:status) { :withdrawn }

      it 'leaves the outcome unchanged without checking eligibility' do
        expect(eligibility_checker).not_to receive(:eligible?)

        expect { finalizer.call }.not_to(change { outcome.reload.attributes })
      end
    end

    context 'when the application has no selection outcome' do
      let!(:outcome) { nil }

      it 'does nothing without checking eligibility' do
        expect(eligibility_checker).not_to receive(:eligible?)

        expect(finalizer.call).to be_nil
      end
    end
  end
end
