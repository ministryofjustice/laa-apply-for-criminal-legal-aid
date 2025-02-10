require 'rails_helper'

RSpec.describe SupportingEvidence::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record: record, crime_application: record) }

  let(:record) {
    instance_double(CrimeApplication, errors: errors, applicant: instance_double(Applicant),
                                              documents: documents, kase: kase, evidence_prompts: evidence_prompts)
  }
  let(:errors) { double(:errors, empty?: false) }
  let(:kase) { instance_double(Case, case_type:) }
  let(:case_type) { nil }
  let(:documents) { double(stored: stored_documents) }
  let(:stored_documents) { [] }
  let(:has_passporting_benefit?) { false }
  let(:evidence_prompts) do
    [
      {
        'id' => 'ExampleRule1',
        'key' => 'example_rule1',
        'run' => {
          'client' => { 'result' => example_prompt_result },
          'partner' => { 'result' => false },
          'other' => { 'result' => false },
        }
      },
      {
        'id' => 'NationalInsuranceRule',
        'key' => 'national_insurance_32',
        'run' => {
          'client' => { 'result' => nino_prompt_result },
          'partner' => { 'result' => false },
          'other' => { 'result' => false },
        }
      }
    ]
  end

  let(:example_prompt_result) { true }
  let(:nino_prompt_result) { false }

  before do
    allow(validator).to receive(:has_passporting_benefit?).and_return(has_passporting_benefit?)
    allow(record).to receive_messages(application_type: ApplicationType::INITIAL.to_s, cifc?: false)
  end

  describe '#validate' do
    before do
      allow(validator).to receive(:benefit_evidence_forthcoming?).and_return(false)
    end

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

    context 'when there are no triggered evidence prompts' do
      let(:example_prompt_result) { false }

      it 'does not add an error' do
        expect(errors).not_to receive(:add).with(:documents, :blank)

        subject.validate
      end
    end

    context 'when the only evidence prompt is for nino evidence' do
      let(:example_prompt_result) { false }
      let(:nino_prompt_result) { true }

      context 'when there is no passporting benefit' do
        it 'does not add an error' do
          expect(errors).not_to receive(:add).with(:documents, :blank)

          subject.validate
        end
      end

      context 'when there is a passporting benefit' do
        let(:has_passporting_benefit?) { true }

        it 'adds errors for all failed validations' do
          expect(errors).to receive(:add).with(:documents, :blank)

          subject.validate
        end
      end
    end

    context 'when benefit evidence is forthcoming' do
      before do
        allow(validator).to receive(:benefit_evidence_forthcoming?).and_return(true)
      end

      context 'and evidence has not been uploaded' do
        it 'adds errors for all failed validations' do
          expect(errors).to receive(:add).with(:documents, :blank)

          subject.validate
        end
      end
    end

    context 'when the application type is change in financial circumstances' do
      before do
        allow(record).to receive_messages(application_type: ApplicationType::CHANGE_IN_FINANCIAL_CIRCUMSTANCES.to_s,
                                          cifc?: true)
      end

      context 'and evidence has not been uploaded' do
        it 'adds errors for all failed validations' do
          expect(errors).to receive(:add).with(:documents, :blank)

          subject.validate
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

  describe '#applicable?' do
    before do
      allow(validator).to receive(:benefit_evidence_forthcoming?).and_return(false)
    end

    context 'when benefit evidence is forthcoming' do
      before do
        allow(validator).to receive(:benefit_evidence_forthcoming?).and_return(true)
      end

      it 'the application does require evidence validation' do
        expect(subject.applicable?).to be(true)
      end
    end

    context 'when the application type is change in financial circumstances' do
      before do
        allow(record).to receive_messages(application_type: ApplicationType::CHANGE_IN_FINANCIAL_CIRCUMSTANCES.to_s,
                                          cifc?: true)
      end

      it 'the application does require evidence validation' do
        expect(subject.applicable?).to be(true)
      end
    end

    context 'when case is indictable' do
      let(:case_type) { CaseType::INDICTABLE.to_s }

      it 'the application does not require evidence validation' do
        expect(subject.applicable?).to be(false)
      end
    end

    context 'when case is in Crown Court' do
      let(:case_type) { CaseType::ALREADY_IN_CROWN_COURT.to_s }

      it 'the application does not require evidence validation' do
        expect(subject.applicable?).to be(false)
      end
    end

    context 'when client is remanded in custody' do
      before do
        allow(kase).to receive_messages(is_client_remanded: 'yes', date_client_remanded: 1.month.ago.to_date)
      end

      it 'the application does not require evidence validation' do
        expect(subject.applicable?).to be(false)
      end
    end

    context 'when the case is neither indictable or in Crown Court and client is not remanded is custody' do
      before do
        allow(kase).to receive_messages(is_client_remanded: 'no')
      end

      it 'the application does require evidence validation' do
        expect(subject.applicable?).to be(true)
      end
    end
  end
end
