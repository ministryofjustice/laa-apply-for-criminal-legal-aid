require 'rails_helper'

RSpec.describe Adapters::Structs::CrimeApplication do
  subject(:application) {
    Adapters::JsonApplication.new(attributes)
  }

  let(:attributes) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }

  describe '#applicant' do
    it 'returns the applicant struct' do
      expect(subject.applicant).to be_a(Adapters::Structs::Applicant)
    end

    it 'sets the benefit_check_result from the means attribute' do
      expect(subject.applicant.benefit_check_result).to be false
    end
  end

  describe '#case' do
    it 'returns the case details struct' do
      expect(subject.case).to be_a(Adapters::Structs::CaseDetails)
    end
  end

  describe '#ioj' do
    it 'returns the interests of justice struct' do
      expect(subject.ioj).to be_a(Adapters::Structs::InterestsOfJustice)
    end
  end

  describe '#income' do
    it 'returns the income struct' do
      expect(subject.income).to be_a(Adapters::Structs::IncomeDetails)
    end
  end

  describe '#outgoings' do
    it 'returns the outgoings struct' do
      expect(subject.outgoings).to be_a(Adapters::Structs::OutgoingsDetails)
    end
  end

  describe '#capital' do
    it 'returns the capital struct' do
      expect(subject.capital).to be_a(Adapters::Structs::CapitalDetails)
    end
  end

  describe '#documents' do
    it 'returns documents' do
      expect(subject.documents).to all(be_a(Document))
    end

    it 'documents are marked as submitted' do
      doc = subject.documents.first
      expect(doc.submitted_at).to eq(subject.submitted_at)
    end
  end

  describe '#dependants' do
    it 'returns dependants' do
      expect(subject.dependants).to all(be_a(Dependant))
    end
  end

  describe '#partner' do
    it 'returns the partner struct' do
      expect(subject.partner).to be_a(Adapters::Structs::Partner)
    end
  end

  describe '#decided?' do
    subject(:decided) { application.decided? }

    context 'when application is `assessment_completed`' do
      let(:attributes) { super().merge(review_status: Types::ReviewApplicationStatus['assessment_completed']) }

      it { is_expected.to be true }
    end

    context 'when application is `returned_to_provider`' do
      let(:attributes) { super().merge(review_status: Types::ReviewApplicationStatus['returned_to_provider']) }

      it { is_expected.to be false }
    end

    context 'when application is `application_received`' do
      let(:attributes) { super().merge(review_status: Types::ReviewApplicationStatus['application_received']) }

      it { is_expected.to be false }
    end

    context 'when application is `ready_for_assessment`' do
      let(:attributes) { super().merge(review_status: Types::ReviewApplicationStatus['ready_for_assessment']) }

      it { is_expected.to be false }
    end
  end

  describe '#funding_decision_missing?' do
    subject(:funding_decision_missing) { application.funding_decision_missing? }

    context 'when application is `assessment_completed`' do
      let(:attributes) { super().merge(review_status: Types::ReviewApplicationStatus['assessment_completed']) }

      context 'when there are no decisions' do
        it { is_expected.to be true }
      end

      context 'when there are no decisions and the application is PSE' do
        let(:attributes) do
          super().merge(application_type: Types::ApplicationType['post_submission_evidence'])
        end

        it { is_expected.to be false }
      end

      context 'when there are decisions' do
        let(:attributes) do
          super().merge(decisions: [LaaCrimeSchemas::Structs::Decision.new])
        end

        it { is_expected.to be false }
      end
    end
  end
end
