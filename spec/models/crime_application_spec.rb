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

  describe '#date_stamp_context' do
    it 'is be persisted and loaded' do
      crime_application = described_class.new
      crime_application.date_stamp_context = DateStampContext.new(
        first_name: 'Sweeny',
        last_name: 'Todd',
        date_of_birth: Date.new(1990, 1, 1),
        date_stamp: Time.current,
      )

      crime_application.save!
      crime_application.reload

      expect(crime_application.date_stamp_context.first_name).to eq 'Sweeny'
      expect(crime_application.date_stamp_context.last_name).to eq 'Todd'
      expect(crime_application.date_stamp_context.date_of_birth.to_s).to eq '1990-01-01'
      expect(crime_application.date_stamp_context.date_stamp).to respond_to :to_time
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

  describe '#decided?' do
    it 'returns false' do
      expect(subject.decided?).to be false
    end
  end

  describe '#to_be_soft_deleted' do
    let(:retention_period) { Rails.configuration.x.retention_period.ago }

    context 'when application has reached the retention period' do
      let(:attributes) { { updated_at: retention_period } }

      before do
        application.save!
      end

      it 'returns application' do
        expect(described_class.to_be_soft_deleted.count).to eq(1)
      end
    end

    context 'when application is older than the retention period' do
      let(:attributes) { { updated_at: retention_period - 1.day } }

      before do
        application.save!
      end

      it 'returns application' do
        expect(described_class.to_be_soft_deleted.count).to eq(1)
      end
    end

    context 'when application is younger than the retention period' do
      let(:attributes) { { updated_at: retention_period + 1.day } }

      before do
        application.save!
      end

      it 'does not return application' do
        expect(described_class.to_be_soft_deleted.count).to eq(0)
      end
    end

    context 'when application is PSE' do
      let(:attributes) {
        { application_type: ApplicationType::POST_SUBMISSION_EVIDENCE.to_s, updated_at: retention_period - 1.day }
      }

      before do
        application.save!
      end

      it 'does not return application' do
        expect(described_class.to_be_soft_deleted.count).to eq(0)
      end
    end

    context 'when application has parent application' do
      let(:attributes) { { parent_id: SecureRandom.uuid, updated_at: retention_period - 1.day } }

      before do
        application.save!
      end

      it 'does not return application' do
        expect(described_class.to_be_soft_deleted.count).to eq(0)
      end
    end

    context 'when application is exempt from deletion' do
      let(:attributes) { { exempt_from_deletion: true, updated_at: retention_period - 1.day } }

      before do
        application.save!
      end

      it 'does not return application' do
        expect(described_class.to_be_soft_deleted.count).to eq(0)
      end
    end
  end

  describe '#to_be_hard_deleted' do
    let(:soft_deletion_period) { Rails.configuration.x.soft_deletion_period.ago }

    context 'when application has reached the soft deletion period' do
      let(:attributes) { { soft_deleted_at: soft_deletion_period } }

      before do
        application.save!
      end

      it 'returns application' do
        expect(described_class.to_be_hard_deleted.count).to eq(1)
      end
    end

    context 'when application is older than the soft deletion period' do
      let(:attributes) { { soft_deleted_at: soft_deletion_period - 1.day } }

      before do
        application.save!
      end

      it 'returns application' do
        expect(described_class.to_be_hard_deleted.count).to eq(1)
      end
    end

    context 'when application is younger than the soft deletion period' do
      let(:attributes) { { soft_deleted_at: soft_deletion_period + 1.day } }

      before do
        application.save!
      end

      it 'does not return application' do
        expect(described_class.to_be_hard_deleted.count).to eq(0)
      end
    end
  end

  describe '#exempt_from_deletion' do
    it 'is false by default' do
      expect(described_class.new.exempt_from_deletion).to be(false)
    end
  end

  describe '#exempt_from_deletion!' do
    let(:attributes) { { soft_deleted_at: Time.zone.now } }

    before { application.save }

    it 'clears soft_deleted_at' do
      expect { application.exempt_from_deletion! }.to change(application, :soft_deleted_at).to(nil)
    end

    it 'sets exempt_from_deletion to true' do
      expect { application.exempt_from_deletion! }.to change(application, :exempt_from_deletion).from(false).to(true)
    end
  end

  describe 'Deleting an application' do
    before { application.save }

    context 'when the application is exempt from deletion' do
      let(:attributes) { { exempt_from_deletion: true } }

      it 'destroy raises an exception' do
        expect {
          application.destroy!
        }.to raise_error(ActiveRecord::RecordNotDestroyed,
                         'Application exempt from deletion').and(not_change(described_class, :count))
      end
    end

    context 'when the application is not exempt from deletion' do
      let(:attributes) { { exempt_from_deletion: false } }

      it 'destroys the application' do
        expect {
          application.destroy!
        }.to change(described_class, :count).from(1).to(0)
      end
    end
  end
end
