require 'rails_helper'

RSpec.describe TypeOfMeansAssessment do
  subject(:assessable) do
    assessable_class.new(crime_application:)
  end

  let(:assessable_class) do
    Struct.new(:crime_application) do
      include TypeOfMeansAssessment
    end
  end

  let(:crime_application) do
    instance_double(CrimeApplication, applicant:, kase:, income:)
  end

  let(:applicant) { instance_double(Applicant) }
  let(:kase) { instance_double(Case) }
  let(:income) { instance_double(Income) }
  let(:means_passporter_result) { false }
  let(:means_passporter) do
    instance_double(Passporting::MeansPassporter, call: means_passporter_result)
  end

  before do
    allow(crime_application).to receive(:appeal_no_changes?)
    allow(Passporting::MeansPassporter).to receive(:new).and_return(means_passporter)
  end

  describe '#benefit_evidence_forthcoming?' do
    subject(:benefit_evidence_forthcoming?) { assessable.benefit_evidence_forthcoming? }

    let(:benefit_type) { BenefitType::JSA.to_s }
    let(:nino) { 'QQ123456A' }

    before do
      allow(applicant).to receive_messages(benefit_type:, nino:)
    end

    context 'when passporting benefit not determined' do
      let(:benefit_type) { nil }

      it { is_expected.to be false }
    end

    context 'when no passporting benefit' do
      let(:benefit_type) { 'none' }

      it { is_expected.to be false }
    end

    context 'when NINO blank' do
      let(:nino) { nil }

      it { is_expected.to be false }
    end

    context 'when dwp result contested but has not evidence' do
      before do
        allow(crime_application).to receive(:confirm_dwp_result).and_return('no')
        allow(applicant).to receive(:has_benefit_evidence).and_return('no')
      end

      it { is_expected.to be false }
    end

    context 'when dwp result confirmed' do
      before do
        allow(crime_application).to receive(:confirm_dwp_result).and_return('yes')
      end

      it { is_expected.to be false }
    end
  end

  describe '#means_assessment_as_benefit_evidence?' do
    subject(:means_assessment_as_benefit_evidence?) { assessable.means_assessment_as_benefit_evidence? }

    let(:benefit_type) { BenefitType::JSA.to_s }
    let(:nino) { 'QQ123456A' }

    before do
      allow(applicant).to receive_messages(benefit_type:, nino:)
    end

    context 'when passporting benefit not determined' do
      let(:benefit_type) { nil }

      it { is_expected.to be false }
    end

    context 'when no passporting benefit' do
      let(:benefit_type) { 'none' }

      it { is_expected.to be false }
    end

    context 'when NINO blank' do
      let(:nino) { nil }

      it { is_expected.to be false }
    end

    context 'when dwp result contested and has evidence' do
      before do
        allow(crime_application).to receive(:confirm_dwp_result).and_return('no')
        allow(applicant).to receive(:has_benefit_evidence).and_return('yes')
      end

      it { is_expected.to be false }
    end

    context 'when dwp result contested but has not evidence' do
      before do
        allow(crime_application).to receive(:confirm_dwp_result).and_return('no')
        allow(applicant).to receive(:has_benefit_evidence).and_return('no')
      end

      it { is_expected.to be true }
    end

    context 'when dwp result confirmed' do
      before do
        allow(crime_application).to receive(:confirm_dwp_result).and_return('yes')
      end

      it { is_expected.to be false }
    end
  end

  describe '#nino_forthcoming?' do
    subject(:nino_forthcoming?) { assessable.nino_forthcoming? }

    let(:benefit_type) { BenefitType::JSA.to_s }
    let(:has_nino) { 'no' }

    before do
      allow(applicant).to receive_messages(benefit_type:, has_nino:)
    end

    context 'when passporting benefit not determined' do
      let(:benefit_type) { nil }

      it { is_expected.to be false }
    end

    context 'when no passporting benefit' do
      let(:benefit_type) { 'none' }

      it { is_expected.to be false }
    end

    context 'when confirmed will not enter NINO' do
      it 'returns true' do
        allow(applicant).to receive(:will_enter_nino).and_return('no')
        expect(subject).to be true
      end
    end

    context 'when will enter NINO' do
      before do
        allow(applicant).to receive(:will_enter_nino).and_return('yes')
      end

      it 'returns false' do
        allow(kase).to receive(:is_client_remanded)
        expect(subject).to be false
      end

      context 'when remanded in custody' do
        it 'returns false' do
          allow(kase).to receive(:is_client_remanded).and_return('yes')
          expect(subject).to be false
        end
      end
    end

    context 'when not known if will enter NINO' do
      before { allow(applicant).to receive(:will_enter_nino) }

      context 'when client remanded' do
        before { allow(kase).to receive(:is_client_remanded).and_return('yes') }

        it { is_expected.to be true }
      end

      context 'when client not remanded' do
        before { allow(kase).to receive(:is_client_remanded).and_return('no') }

        it { is_expected.to be false }
      end

      context 'when not known if client remanded' do
        before { allow(kase).to receive(:is_client_remanded) }

        it { is_expected.to be false }
      end
    end
  end

  describe '#evidence_of_passporting_means_forthcoming?' do
    subject(:evidence_of_passporting_means_forthcoming?) { assessable.evidence_of_passporting_means_forthcoming? }

    let(:benefit_type) { BenefitType::JSA.to_s }

    before do
      allow(applicant).to receive(:benefit_type).and_return(benefit_type)
    end

    context 'when passporting benefit not determined' do
      let(:benefit_type) { nil }

      it { is_expected.to be false }
    end

    context 'when no passporting benefit' do
      let(:benefit_type) { 'none' }

      it { is_expected.to be false }
    end

    context 'when nino forthcoming' do
      before do
        allow(assessable).to receive_messages(
          benefit_evidence_forthcoming?: false,
          nino_forthcoming?: true
        )
      end

      it { is_expected.to be true }
    end

    context 'when benefit evidence is forthcoming' do
      before do
        allow(assessable).to receive_messages(
          benefit_evidence_forthcoming?: true,
          nino_forthcoming?: false
        )
      end

      it { is_expected.to be true }
    end

    context 'when neither benefit evidence nor NINO forthcoming' do
      before do
        allow(assessable).to receive_messages(
          benefit_evidence_forthcoming?: false,
          nino_forthcoming?: false
        )
      end

      it { is_expected.to be false }
    end
  end

  describe '#requires_means_assessment?' do
    subject(:requires_means_assessment?) { assessable.requires_means_assessment? }

    context 'when means journey FeatureFlag is disabled' do
      before do
        allow(FeatureFlags).to receive(:means_journey).and_return(
          instance_double(FeatureFlags::EnabledFeature, enabled?: false)
        )
      end

      it { is_expected.to be false }
    end

    context 'when means passported' do
      let(:means_passporter_result) { true }

      it { is_expected.to be false }
    end

    context 'when benefit none' do
      before { allow(applicant).to receive(:benefit_type).and_return('none') }

      it { is_expected.to be true }
    end

    context 'when appeal no changes' do
      before { allow(crime_application).to receive(:appeal_no_changes?).and_return(true) }

      it { is_expected.to be false }
    end

    context 'when evidence of passporting means forthcoming?' do
      before do
        allow(assessable).to receive(:evidence_of_passporting_means_forthcoming?).and_return(true)
      end

      it { is_expected.to be false }
    end

    context 'when evidence of passporting means is not forthcoming?' do
      before do
        allow(assessable).to receive(:evidence_of_passporting_means_forthcoming?).and_return(false)
      end

      it { is_expected.to be true }
    end
  end

  describe '#requires_full_means_assessment?' do
    subject(:requires_full_means_assessment?) { assessable.requires_full_means_assessment? }

    context 'when means assessment not required' do
      before do
        allow(assessable).to receive(:requires_means_assessment?).and_return(false)
      end

      it { is_expected.to be false }
    end

    context 'when requires means assessment' do
      before do
        allow(assessable).to receive(:requires_means_assessment?).and_return(true)
      end

      context 'income is above threshold' do
        before do
          allow(income).to receive(:income_above_threshold).and_return('yes')
        end

        it { is_expected.to be true }
      end

      context 'client has frozen assets' do
        before do
          allow(income).to receive(:income_above_threshold)
          allow(income).to receive(:has_frozen_income_or_assets).and_return('yes')
        end

        it { is_expected.to be true }
      end

      context 'has no frozen assets and income is below threshold' do
        before do
          allow(income).to receive_messages(
            income_above_threshold: 'no',
            has_frozen_income_or_assets: 'no'
          )
        end

        context 'and case is summary only' do
          before do
            allow(kase).to receive(:case_type).and_return('summary_only')
          end

          it { is_expected.to be false }
        end

        context 'and has no savings or property' do
          before do
            allow(income).to receive_messages(
              client_owns_property: 'no',
              has_savings: 'no'
            )

            allow(kase).to receive(:case_type)
          end

          it { is_expected.to be false }
        end
      end
    end
  end

  describe '#requires_full_capital?' do
    subject(:requires_full_capital?) { assessable.requires_full_capital? }

    before { allow(kase).to receive(:case_type).and_return(case_type) }

    let(:case_type) { 'committal' }

    context 'when case is nil' do
      let(:case_type) { nil }

      it { is_expected.to be false }
    end

    context 'when case is either way' do
      let(:case_type) { 'either_way' }

      it { is_expected.to be true }
    end

    context 'when case is indictable' do
      let(:case_type) { 'indictable' }

      it { is_expected.to be true }
    end

    context 'when case is already in crown courst' do
      let(:case_type) { 'already_in_crown_court' }

      it { is_expected.to be true }
    end

    context 'when case is summary only' do
      let(:case_type) { 'summary_only' }

      it { is_expected.to be false }
    end
  end
end
