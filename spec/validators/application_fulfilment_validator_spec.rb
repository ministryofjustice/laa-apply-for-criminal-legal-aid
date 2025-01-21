require 'rails_helper'

module Test
  CrimeApplicationValidatable = Struct.new(:is_means_tested, :kase, :ioj, :income, :documents, :applicant, :cifc?,
                                           :application_type, keyword_init: true) do
    include ActiveModel::Validations
    validates_with ApplicationFulfilmentValidator

    def appeal_no_changes?
      false
    end

    def to_param
      '12345'
    end
  end
end

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe ApplicationFulfilmentValidator, type: :model do
  subject { Test::CrimeApplicationValidatable.new(arguments) }

  let(:arguments) do
    {
      is_means_tested: is_means_tested,
      kase: kase,
      applicant: applicant,
      ioj: ioj,
      income: income,
      documents: documents,
      cifc?: cifc?,
      application_type: ApplicationType::INITIAL.to_s
    }
  end

  let(:is_means_tested) { 'yes' }

  let(:kase) {
    instance_double(Case, case_type:, is_client_remanded:, date_client_remanded:)
  }

  let(:applicant) { instance_double(Applicant, benefit_type: 'none') }
  let(:is_client_remanded) { nil }
  let(:date_client_remanded) { nil }
  let(:case_type) { 'either_way' }
  let(:ioj) { instance_double(Ioj, types: ioj_types) }
  let(:ioj_types) { [] }
  let(:income) { instance_double(Income, employment_status:) }
  let(:employment_status) { [] }
  let(:documents) { double(stored: stored_documents) }
  let(:stored_documents) { [] }

  let(:cifc?) { false }

  context 'MeansPassporter validation' do
    before do
      allow_any_instance_of(Passporting::MeansPassporter).to receive(:call).and_return(means_result)

      # stub the other validation
      allow_any_instance_of(Passporting::IojPassporter).to receive(:call).and_return(true)
      allow_any_instance_of(SupportingEvidence::AnswersValidator).to receive(:evidence_complete?).and_return(true)
      allow_any_instance_of(SupportingEvidence::AnswersValidator).to receive(:applicable?).and_return(true)
    end

    context 'when the application is means-passported' do
      let(:means_result) { true }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'when the application is not means-passported' do
      let(:means_result) { false }

      context 'and means details have been recorded' do
        context 'employment_status is not_working' do
          let(:employment_status) { ['not_working'] }

          it 'is valid' do
            expect(subject).to be_valid
          end
        end

        context 'employment_status is employed' do
          let(:employment_status) { ['employed'] }

          it 'is valid' do
            expect(subject).to be_valid
          end
        end
      end

      context 'and means details have not been recorded' do
        let(:employment_status) { [] }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:means_passport, :blank)).to be(true)
          expect(subject.errors.first.details[:change_path]).to eq('/applications/12345/steps/client/details')
        end
      end

      context 'and applicant is in Court Custody' do
        let(:is_client_remanded) { 'yes' }
        let(:date_client_remanded) { Time.zone.today }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end

  context 'IojPassporter validation' do
    before do
      allow_any_instance_of(Passporting::IojPassporter).to receive(:call).and_return(ioj_result)

      # stub the other validation
      allow_any_instance_of(Passporting::MeansPassporter).to receive(:call).and_return(true)
      allow_any_instance_of(SupportingEvidence::AnswersValidator).to receive(:evidence_complete?).and_return(true)
      allow_any_instance_of(SupportingEvidence::AnswersValidator).to receive(:applicable?).and_return(true)
    end

    context 'when the application is ioj-passported' do
      let(:ioj_result) { true }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'when the application is not ioj-passported' do
      let(:ioj_result) { false }

      context 'and there are no IoJ reasons' do
        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:ioj_passport, :blank)).to be(true)
          expect(subject.errors.first.details[:change_path]).to eq('/applications/12345/steps/case/ioj')
        end
      end

      context 'and there are IoJ reasons' do
        let(:ioj_types) { [:foo, :bar] }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end

  context 'CaseType validation' do
    before do
      # stub the other validations
      allow_any_instance_of(Passporting::MeansPassporter).to receive(:call).and_return(true)
      allow_any_instance_of(Passporting::IojPassporter).to receive(:call).and_return(true)
      allow_any_instance_of(SupportingEvidence::AnswersValidator).to receive(:evidence_complete?).and_return(true)
      allow_any_instance_of(SupportingEvidence::AnswersValidator).to receive(:applicable?).and_return(true)
    end

    context 'when the application has a case type' do
      let(:case_type) { 'either_way' }
      let(:is_means_tested) { 'yes' }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'when the application is missing a case type' do
      let(:case_type) { nil }

      context 'and application is not means tested' do
        let(:is_means_tested) { 'no' }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'and application is means tested' do
        let(:is_means_tested) { 'yes' }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:base, :case_type_missing)).to be(true)
          expect(subject.errors.first.details[:change_path]).to eq('/applications/12345/steps/client/case-type')
        end
      end
    end
  end

  # Note the validator logic is tested in validators/supporting_evidence/answers_validator_spec.rb
  context 'Supporting evidence validation' do
    before do
      # stub the other validations
      allow_any_instance_of(Passporting::MeansPassporter).to receive(:call).and_return(true)
      allow_any_instance_of(Passporting::IojPassporter).to receive(:call).and_return(true)
    end

    context 'when the required evidence has not been uploaded' do
      before do
        allow_any_instance_of(SupportingEvidence::AnswersValidator).to receive(:applicable?).and_return(true)
        allow_any_instance_of(SupportingEvidence::AnswersValidator).to receive(:evidence_complete?).and_return(false)
      end

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:documents, :blank)).to be(true)
        expect(subject.errors.first.details[:change_path]).to eq('/applications/12345/steps/evidence/upload')
      end
    end

    context 'when the required evidence has been uploaded' do
      before do
        allow_any_instance_of(SupportingEvidence::AnswersValidator).to receive(:applicable?).and_return(true)
        allow_any_instance_of(SupportingEvidence::AnswersValidator).to receive(:evidence_complete?).and_return(true)
      end

      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end

  context 'when application is Change in Financial Circumstances' do
    let(:cifc?) { true }

    context 'with completed fields' do
      before do
        allow_any_instance_of(SupportingEvidence::AnswersValidator).to(
          receive(:evidence_complete?).and_return(true)
        )

        allow_any_instance_of(SupportingEvidence::AnswersValidator).to(
          receive(:applicable?).and_return(true)
        )

        allow_any_instance_of(Circumstances::AnswersValidator).to(
          receive(:circumstances_reference_complete?).and_return(true)
        )

        allow_any_instance_of(Circumstances::AnswersValidator).to(
          receive(:circumstances_reason_complete?).and_return(true)
        )
      end

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'with incomplete reference fields' do
      before do
        allow_any_instance_of(SupportingEvidence::AnswersValidator).to(
          receive(:evidence_complete?).and_return(true)
        )

        allow_any_instance_of(SupportingEvidence::AnswersValidator).to(
          receive(:applicable?).and_return(true)
        )

        allow_any_instance_of(Circumstances::AnswersValidator).to(
          receive(:circumstances_reference_complete?).and_return(false)
        )

        allow_any_instance_of(Circumstances::AnswersValidator).to(
          receive(:circumstances_reason_complete?).and_return(true)
        )
      end

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:base, :circumstances_reference)).to be(true)
      end
    end

    context 'with incomplete reason field' do
      before do
        allow_any_instance_of(SupportingEvidence::AnswersValidator).to(
          receive(:evidence_complete?).and_return(true)
        )

        allow_any_instance_of(SupportingEvidence::AnswersValidator).to(
          receive(:applicable?).and_return(true)
        )

        allow_any_instance_of(Circumstances::AnswersValidator).to(
          receive(:circumstances_reference_complete?).and_return(true)
        )

        allow_any_instance_of(Circumstances::AnswersValidator).to(
          receive(:circumstances_reason_complete?).and_return(false)
        )
      end

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:base, :circumstances_reason)).to be(true)
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
