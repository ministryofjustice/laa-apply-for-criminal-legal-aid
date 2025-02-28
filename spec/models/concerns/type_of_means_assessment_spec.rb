require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
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
    instance_double(
      CrimeApplication,
      applicant: applicant,
      partner: partner,
      kase: kase,
      income: income,
      partner_detail: partner_detail,
      non_means_tested?: false
    )
  end

  let(:applicant) { instance_double(Applicant, has_benefit_evidence:, residence_type:) }
  let(:partner) { nil }
  let(:benefit_check_subject) { applicant }
  let(:has_benefit_evidence) { nil }
  let(:residence_type) { nil }
  let(:kase) { instance_double(Case) }
  let(:income) { instance_double(Income) }
  let(:means_passporter_result) { false }
  let(:means_passporter) do
    instance_double(Passporting::MeansPassporter, call: means_passporter_result)
  end
  let(:partner_detail) { nil }

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

    context 'when dwp result contested and has no evidence' do
      let(:has_benefit_evidence) { 'no' }

      before do
        allow(applicant).to receive(:confirm_dwp_result).and_return('no')
      end

      it { is_expected.to be false }
    end

    context 'when dwp result confirmed' do
      before do
        allow(applicant).to receive(:confirm_dwp_result).and_return('yes')
      end

      it { is_expected.to be false }
    end
  end

  describe '#include_partner_in_means_assessment?' do
    subject(:include_partner_in_means_assessment?) do
      assessable.include_partner_in_means_assessment?
    end

    context 'when it is not yet known if the client has a partner' do
      it { is_expected.to be false }
    end

    context 'when the client does not have partner' do
      let(:partner_detail) do
        instance_double(PartnerDetail, has_partner: 'no', involvement_in_case: nil)
      end

      it { is_expected.to be false }
    end

    context 'when client has a partner but we do not know their involvement' do
      let(:partner_detail) do
        instance_double(PartnerDetail, has_partner: 'yes', involvement_in_case: nil)
      end

      it { is_expected.to be false }
    end

    context 'when client has a partner and they are not involved in the case' do
      let(:partner_detail) do
        instance_double(PartnerDetail, involvement_in_case: 'none', has_partner: 'yes')
      end

      it { is_expected.to be true }
    end

    context 'when client has a partner and they are a prosecution witness' do
      let(:partner_detail) do
        instance_double(PartnerDetail, involvement_in_case: 'prosecution_witness', has_partner: 'yes')
      end

      it { is_expected.to be false }
    end

    context 'when client has a partner and they are a victim' do
      let(:partner_detail) do
        instance_double(PartnerDetail, involvement_in_case: 'victim', has_partner: 'yes')
      end

      it { is_expected.to be false }
    end

    context 'when client has a partner and they are a codefendant' do
      let(:partner_detail) do
        instance_double(
          PartnerDetail,
          involvement_in_case: 'codefendant',
          conflict_of_interest: conflict_of_interest,
          has_partner: 'yes',
        )
      end

      context 'when there is a conflict of interest' do
        let(:conflict_of_interest) { 'yes' }

        it { is_expected.to be false }
      end

      context 'when there is no conflict of interest' do
        let(:conflict_of_interest) { 'no' }

        it { is_expected.to be true }
      end
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
        allow(applicant).to receive_messages(confirm_dwp_result: 'no', has_benefit_evidence: 'yes')
      end

      it { is_expected.to be false }
    end

    context 'when dwp result contested and has no evidence' do
      before do
        allow(applicant).to receive_messages(confirm_dwp_result: 'no', has_benefit_evidence: 'no')
      end

      it { is_expected.to be true }
    end

    context 'when dwp result confirmed' do
      before do
        allow(applicant).to receive(:confirm_dwp_result).and_return('yes')
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

    before do
      allow(income).to receive_messages(partner_self_employed?: false, client_self_employed?: false)
    end

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

      context 'when client is self employed' do
        before do
          allow(income).to receive_messages(
            income_above_threshold: 'no',
            has_frozen_income_or_assets: 'no',
            client_self_employed?: true
          )
        end

        it { is_expected.to be true }
      end

      context 'when partner is self employed' do
        before do
          allow(income).to receive_messages(
            income_above_threshold: 'no',
            has_frozen_income_or_assets: 'no',
            partner_self_employed?: true
          )
        end

        context 'when partner not means assessed' do
          let(:partner_detail) { instance_double(PartnerDetail, involvement_in_case: 'victim') }

          before do
            allow(income).to receive_messages(
              client_owns_property: 'no',
              has_savings: 'no'
            )
            allow(kase).to receive(:case_type)
          end

          it { is_expected.to be false }
        end

        context 'when partner means assessed' do
          let(:partner_detail) { instance_double(PartnerDetail, involvement_in_case: 'none') }

          it { is_expected.to be true }
        end
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

  describe '#benefit_check_subject' do
    subject(:benefit_check_subject) do
      assessable.benefit_check_subject
    end

    context 'when partner is not included in means assessment' do
      let(:partner_detail) { instance_double(PartnerDetail, involvement_in_case: 'victim') }

      it { is_expected.to be applicant }
    end

    context 'when applicant is benefit check recipient' do
      let(:partner_detail) { instance_double(PartnerDetail, involvement_in_case: 'none') }
      let(:benefit_type) { BenefitType::UNIVERSAL_CREDIT.to_s }

      before do
        allow(applicant).to receive_messages(benefit_type: benefit_type, arc: nil)
      end

      it { is_expected.to be applicant }
    end

    context 'when partner is benefit check recipient' do
      let(:partner) { instance_double(Partner) }
      let(:partner_detail) { instance_double(PartnerDetail, involvement_in_case: 'none') }

      context 'when applicant benefit type is none' do
        before do
          allow(applicant).to receive(:benefit_type).and_return('none')
          allow(partner).to receive_messages(benefit_type: BenefitType::UNIVERSAL_CREDIT.to_s, arc: nil)
        end

        it { is_expected.to be partner }
      end

      context 'when applicant benefit type has an arc' do
        before do
          allow(applicant).to receive_messages(benefit_type: nil, arc: 'ABC12/345678/A')
          allow(partner).to receive_messages(benefit_type: BenefitType::UNIVERSAL_CREDIT.to_s, arc: nil)
        end

        it { is_expected.to be partner }
      end
    end

    context 'defaults to applicant' do
      let(:partner) { instance_double(Partner) }
      let(:partner_detail) { instance_double(PartnerDetail, involvement_in_case: 'none') }

      context 'when both the applicant and partner benefit type is none' do
        before do
          allow(applicant).to receive(:benefit_type).and_return('none')
          allow(partner).to receive(:benefit_type).and_return('none')
        end

        it { is_expected.to be applicant }
      end

      context 'when both the applicant and partner have arc numbers' do
        before do
          allow(applicant).to receive_messages(benefit_type: nil, arc: 'ABC12/345678/A')
          allow(partner).to receive_messages(benefit_type: nil, arc: 'ABC12/345678/A')
        end

        it { is_expected.to be applicant }
      end

      context 'when partner is nil' do
        let(:partner) { nil }

        before do
          allow(applicant).to receive(:benefit_type).and_return('none')
        end

        it { is_expected.to be applicant }
      end
    end
  end

  describe '#insufficient_income_declared?' do
    subject(:insufficient_income_declared?) do
      assessable.insufficient_income_declared?
    end

    context 'when income is more than zero' do
      before do
        allow(income).to receive_messages(all_income_over_zero?: true, client_self_employed?: false,
                                          partner_self_employed?: false)
      end

      it { is_expected.to be false }
    end

    context 'when the client is self-employed' do
      before do
        allow(income).to receive_messages(all_income_over_zero?: false, client_self_employed?: true,
                                          partner_self_employed?: false)
      end

      it { is_expected.to be false }
    end

    context 'when the partner is self-employed' do
      before do
        allow(income).to receive_messages(all_income_over_zero?: false, client_self_employed?: false,
                                          partner_self_employed?: true)
      end

      it { is_expected.to be false }
    end

    context 'when there is no income and neither the client or partner are self-employed' do
      before do
        allow(income).to receive_messages(all_income_over_zero?: false, client_self_employed?: false,
                                          partner_self_employed?: false)
      end

      it { is_expected.to be true }
    end
  end

  describe '#residence_owned?' do
    subject(:residence_owned?) { assessable.residence_owned? }

    context 'when `residence_type` is nil' do
      let(:residence_type) { nil }

      it { is_expected.to be false }
    end

    context 'when `residence_type` is not an owned property' do
      let(:residence_type) { ResidenceType::RENTED.to_s }

      it { is_expected.to be false }
    end

    {
      ResidenceType::APPLICANT_OWNED.to_s => 'they own',
      ResidenceType::JOINT_OWNED.to_s => 'they and their partner both own'
    }.each do |type, desc|
      context "when `residence_type` is a property #{desc}" do
        let(:residence_type) { type }

        it { is_expected.to be true }
      end
    end

    context 'when `residence_type` is a property the partner owns' do
      let(:residence_type) { ResidenceType::PARTNER_OWNED.to_s }

      context 'and there is no conflict of interest' do
        let(:partner_detail) do
          instance_double(PartnerDetail, involvement_in_case: 'none', has_partner: 'yes')
        end

        it { is_expected.to be true }
      end

      context 'and there is a conflict of interest' do
        let(:partner_detail) do
          instance_double(PartnerDetail, involvement_in_case: 'codefendant', has_partner: 'yes',
conflict_of_interest: 'yes')
        end

        it { is_expected.to be false }
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
