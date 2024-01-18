require 'rails_helper'

RSpec.describe PostSubmissionEvidence::FindOrCreate do
  subject(:service) { described_class.new(initial_application:) }

  let(:initial_application) do
    instance_double(Adapters::Structs::CrimeApplication, reference:, id:, applicant:, provider_details:)
  end

  let(:reference) { 1_000_023 }
  let(:id) { SecureRandom.uuid }
  let(:applicant) { instance_double(Adapters::Structs::Applicant, serializable_hash: {}) }
  let(:provider_details) { double(office_code: 'An0Fi5') }

  describe '#call' do
    context 'when initial_application cannot receive pse' do
      before do
        allow(initial_application).to receive(:can_receive_pse?).and_return(false)
      end

      it 'raises Errors::ApplicationCannotReceivePse' do
        expect { service.call }.to raise_error(Errors::ApplicationCannotReceivePse)
      end
    end

    context 'when initial_application can receive pse' do
      let(:existing_pse) { nil }

      before do
        allow(initial_application).to receive(:can_receive_pse?).and_return(true)
        allow(CrimeApplication).to receive(:find_by).with(usn: reference).and_return(existing_pse)
      end

      it 'creates a new CrimeApplication record with the expected attributes' do
        expect(CrimeApplication).to receive(:create!).with(
          usn: reference,
          parent_id: id,
          office_code: 'An0Fi5',
          applicant: an_instance_of(Applicant),
          application_type: ApplicationType::POST_SUBMISSION_EVIDENCE
        )

        service.call
      end

      context 'when `in_progress` PSE for the initial application exists' do
        let(:existing_pse) { instance_double(CrimeApplication) }

        it 'returns the in progress PSE' do
          expect(CrimeApplication).not_to receive(:create!)

          expect(service.call).to eq existing_pse
        end
      end
    end
  end
end
