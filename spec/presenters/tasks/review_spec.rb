require 'rails_helper'

RSpec.describe Tasks::Review do
  subject(:task) { described_class.new(crime_application:) }

  let(:crime_application) do
    CrimeApplication.new(
      legal_rep_first_name:,
      legal_rep_last_name:,
      legal_rep_telephone:,
    )
  end

  let(:legal_rep_first_name) { nil }
  let(:legal_rep_last_name) { nil }
  let(:legal_rep_telephone) { nil }

  before do
    allow(crime_application).to receive(:id).and_return('12345')
  end

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/submission/review') }
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to be(false) }
  end

  describe '#can_start?' do
    subject(:can_start?) { task.can_start? }

    context 'when an initial application' do
      let(:required_task_classes) do
        [
          Tasks::ClientDetails,
          Tasks::PassportingBenefitCheck,
          Tasks::CaseDetails,
          Tasks::Ioj,
          Tasks::IncomeAssessment,
          Tasks::OutgoingsAssessment,
          Tasks::CapitalAssessment,
          Tasks::MoreInformation
        ]
      end

      before do
        required_task_classes.each do |klass|
          allow(task).to receive(:fulfilled?).with(klass).and_return(true)
        end
      end

      context 'when all the required tasks have been completed or are not applicable' do
        before do
          required_task_classes.each do |klass|
            allow(task).to receive(:fulfilled?).with(klass).and_return(true)
          end
        end

        it { is_expected.to be(true) }
      end

      context 'when the Case details have not been completed' do
        before do
          allow(task).to receive(:fulfilled?).with(required_task_classes.first).and_return(false)
        end

        it { is_expected.to be(false) }
      end
    end

    context 'when the application is PSE' do
      before do
        allow(task).to receive(:fulfilled?).with(Tasks::EvidenceUpload).and_return(
          evidence_fulfilled
        )

        allow(task).to receive(:fulfilled?).with(Tasks::MoreInformation).and_return(true)

        allow(crime_application).to receive(:pse?).and_return(true)
      end

      context 'when the evidence task has been completed' do
        let(:evidence_fulfilled) { true }

        it { is_expected.to be(true) }
      end

      context 'when the evidence task has not been completed yet' do
        let(:evidence_fulfilled) { false }

        it { is_expected.to be(false) }
      end
    end
  end

  describe '#in_progress?' do
    it { expect(subject.in_progress?).to be(true) }
  end

  describe '#completed?' do
    context 'when the Declaration task has some value' do
      let(:legal_rep_first_name) { 'John' }

      it { expect(subject.completed?).to be(true) }
    end

    context 'when the Declaration task has no values yet' do
      it { expect(subject.completed?).to be(false) }
    end
  end
end
