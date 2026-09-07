require 'rails_helper'

RSpec.describe Slipstream::PersistSelectionOutcome do
  subject(:persister) { described_class.new(crime_application) }

  let(:crime_application) { CrimeApplication.create! }
  let(:selector) { instance_double(Slipstream::CandidateSelector, call: status) }
  let(:status) { :selected }
  let(:sampled_at) { Time.zone.parse('2026-09-03 10:00:00') }

  before do
    allow(Slipstream::CandidateSelector).to receive(:new)
      .with(crime_application, sample_rate: 10)
      .and_return(selector)
    allow(Time).to receive(:current).and_return(sampled_at)
  end

  describe '#call' do
    it 'persists the sampling outcome and metadata' do
      outcome = persister.call

      expect(outcome).to have_attributes(
        crime_application: crime_application,
        status: 'selected',
        sample_rate: 10,
        sampled_at: sampled_at,
        status_determined_at: sampled_at
      )
    end

    context 'when the application is not selected' do
      let(:status) { :not_selected }

      it 'persists the not-selected outcome' do
        expect(persister.call).to be_not_selected
      end
    end

    context 'when the application is ineligible' do
      let(:status) { nil }

      it 'does not persist an outcome' do
        expect { persister.call }.not_to change(SlipstreamAuditSelectionOutcome, :count)
      end
    end

    context 'when an outcome already exists' do
      let!(:existing_outcome) do
        crime_application.create_slipstream_audit_selection_outcome!(
          status: :not_selected,
          sample_rate: 5,
          sampled_at: sampled_at,
          status_determined_at: sampled_at
        )
      end

      it 'returns the existing outcome without sampling again' do
        expect(selector).not_to receive(:call)

        expect(persister.call).to eq(existing_outcome)
      end
    end
  end
end
