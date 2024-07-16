require 'rails_helper'

RSpec.describe SupportingEvidence::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record: record, crime_application: record) }

  let(:record) {
    instance_double(CrimeApplication, errors:, applicant:, documents:, kase:, evidence_prompts:)
  }
  let(:errors) { double(:errors, empty?: false) }
  let(:applicant) { instance_double(Applicant) }
  let(:kase) { instance_double(Case, case_type:) }
  let(:case_type) { nil }
  let(:documents) { double(stored: stored_documents) }
  let(:stored_documents) { [] }

  let(:evidence_prompts) do
    [
      {
        'id' => 'ExampleRule1',
        'key' => prompt_key,
        'run' => {
          'client' => { 'result' => result },
          'partner' => { 'result' => false },
          'other' => { 'result' => false },
        }
      }
    ]
  end

  let(:prompt_key) { 'example_rule1' }
  let(:result) { true }

  before do
    allow(validator).to receive(:has_passporting_benefit?).and_return(false)
  end

  describe '#validate' do
    context 'when validation fails' do
      it 'adds errors for all failed validations' do
        expect(errors).to receive(:add).with(:documents, :blank)

        subject.validate
      end
    end

    context 'when evidence is present' do
      let(:stored_documents) { [Document.new] }

      it 'does not add an error' do
        expect(errors).not_to receive(:add).with(:documents, :blank)

        subject.validate
      end
    end

    context 'when case is indictable' do
      let(:case_type) { CaseType::INDICTABLE.to_s }

      it 'does not add an error' do
        expect(errors).not_to receive(:add).with(:documents, :blank)

        subject.validate
      end
    end

    context 'when case is in crown court' do
      let(:case_type) { CaseType::ALREADY_IN_CROWN_COURT.to_s }

      it 'does not add an error' do
        expect(errors).not_to receive(:add).with(:documents, :blank)

        subject.validate
      end
    end

    context 'when there are no evidence prompts' do
      let(:result) { false }

      it 'does not add an error' do
        expect(errors).not_to receive(:add).with(:documents, :blank)

        subject.validate
      end
    end

    context 'the only evidence prompt is for nino evidence' do
      let(:prompt_key) { :national_insurance_32 }

      context 'when there is a passporting benefit' do
        before do
          allow(validator).to receive(:has_passporting_benefit?).and_return(true)
        end

        context 'when applicant is not remanded in custody' do
          before do
            allow(kase).to receive_messages(is_client_remanded: 'no')
          end

          it 'adds errors for all failed validations' do
            expect(errors).to receive(:add).with(:documents, :blank)

            subject.validate
          end
        end

        context 'when client is remanded in custody' do
          before do
            allow(kase).to receive_messages(is_client_remanded: 'yes', date_client_remanded: 1.month.ago.to_date)
          end

          it 'does not add an error' do
            expect(errors).not_to receive(:add).with(:documents, :blank)

            subject.validate
          end
        end
      end
    end
  end

  describe '#complete?' do
    context 'when errors are present' do
      before do
        allow(validator).to receive(:validate).and_return(false)
      end

      it { expect(subject.complete?).to be(false) }
    end

    context 'when errors is empty' do
      let(:errors) { double(:errors, empty?: true) }

      before do
        allow(validator).to receive(:validate).and_return(true)
      end

      it { expect(subject.complete?).to be(true) }
    end
  end
end
