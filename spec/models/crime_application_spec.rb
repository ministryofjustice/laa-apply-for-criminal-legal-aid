require 'rails_helper'

RSpec.describe CrimeApplication, type: :model do
  subject(:application) { described_class.new(attributes) }

  let(:attributes) { {} }

  describe 'status enum' do
    it 'has the right values' do
      expect(
        described_class.statuses
      ).to eq(
        'in_progress' => 'in_progress',
      )
    end
  end

  describe '#not_means_tested?' do
    context 'when application is not means tested' do
      let(:attributes) { { is_means_tested: 'no' } }

      it 'has the right value' do
        expect(subject.not_means_tested?).to be(true)
      end
    end

    context 'when application is means tested' do
      let(:attributes) { { is_means_tested: 'yes' } }

      it 'has the right value' do
        expect(subject.not_means_tested?).to be(false)
      end
    end

    context 'when is means tested is nil' do
      let(:attributes) { { is_means_tested: nil } }

      it 'has the right value' do
        expect(subject.not_means_tested?).to be(false)
      end
    end
  end

  describe '#date_stamp' do
    subject(:date_stamp) { application.date_stamp }

    let(:stored_date_stamp) { '2024-01-01' }

    before do
      application.date_stamp = stored_date_stamp
      application.case = Case.new(case_type:)
    end

    context 'when #case#case_type is passportable' do
      let(:case_type) { CaseType::DATE_STAMPABLE.sample.to_s }

      it { is_expected.to eq stored_date_stamp }
    end

    context 'when #case#case_type is not passportable' do
      let(:case_type) { (CaseType::VALUES - CaseType::DATE_STAMPABLE).sample.to_s }

      it { is_expected.to be_nil }
    end

    context 'when #case is nil' do
      let(:case_type) { nil }

      before { application.case = nil }

      it { is_expected.to be_nil }
    end

    context 'when #case#case_type is nil' do
      let(:case_type) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe 'evidence' do
    it 'has an initial empty prompts' do
      expect(subject.evidence_prompts).to eq []
    end

    it 'has no evidence last run at' do
      expect(subject.evidence_last_run_at).to be_nil
    end
  end

  it 'has an initial status value of "in_progress"' do
    expect(subject.status).to eq('in_progress')
  end

  describe '#passporting_benefit_complete?' do
    let(:attributes) { { applicant: } }

    let(:applicant) do
      Applicant.new(benefit_type: nil, date_of_birth: '1970-05-05')
    end

    before do
      allow_any_instance_of(Passporting::MeansPassporter).to receive(:call).and_return(false)
    end

    it 'returns false' do
      expect(subject.passporting_benefit_complete?).to be false
    end
  end

  it_behaves_like 'it has a means ownership scope'
end
