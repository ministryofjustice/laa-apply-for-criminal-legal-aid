require 'rails_helper'

RSpec.describe Case::HasOtherCharges do
  let(:has_other_charges) do
    Case.new(
      crime_application:,
      case_type:,
      client_other_charge:,
      partner_other_charge:
    )
  end

  let(:crime_application) do
    CrimeApplication.new(
      partner:,
      partner_detail:
    )
  end

  let(:partner) { Partner.new }
  let(:partner_detail) { PartnerDetail.new(involvement_in_case:, conflict_of_interest:) }
  let(:involvement_in_case) { nil }
  let(:conflict_of_interest) { nil }

  let(:case_type) { nil }
  let(:client_other_charge) { nil }
  let(:partner_other_charge) { nil }

  describe '#client_other_charge_in_progress' do
    subject(:client_other_charge_in_progress) { has_other_charges.client_other_charge_in_progress }

    before { has_other_charges.client_other_charge_in_progress = 'yes' }

    context 'when `client_other_charge_in_progress` is required' do
      before { allow(has_other_charges).to receive(:require_client_other_charge_in_progress?).and_return(true) }

      it { is_expected.to eq('yes') }
    end

    context 'when `client_other_charge_in_progress` is not required' do
      before { allow(has_other_charges).to receive(:require_client_other_charge_in_progress?).and_return(false) }

      it { is_expected.to be_nil }
    end
  end

  describe '#partner_other_charge_in_progress' do
    subject(:partner_other_charge_in_progress) { has_other_charges.partner_other_charge_in_progress }

    before { has_other_charges.partner_other_charge_in_progress = 'yes' }

    context 'when `partner_other_charge_in_progress` is required' do
      before { allow(has_other_charges).to receive(:require_partner_other_charge_in_progress?).and_return(true) }

      it { is_expected.to eq('yes') }
    end

    context 'when `partner_other_charge_in_progress` is not required' do
      before { allow(has_other_charges).to receive(:require_partner_other_charge_in_progress?).and_return(false) }

      it { is_expected.to be_nil }
    end
  end

  describe '#client_other_charge' do
    subject(:kase) do
      has_other_charges.save
      has_other_charges
    end

    let(:client_other_charge) { OtherCharge.create(ownership_type: OwnershipType::APPLICANT.to_s) }

    context 'when other charge is required' do
      before { allow(kase).to receive(:require_client_other_charge?).and_return(true) }

      it 'returns the other charge' do
        expect(kase.client_other_charge).to eq(client_other_charge)
      end
    end

    context 'when other charges are not required' do
      before { allow(kase).to receive(:require_client_other_charge?).and_return(false) }

      it 'returns nil' do
        expect(kase.client_other_charge).to be_nil
      end
    end
  end

  describe '#partner_other_charge' do
    subject(:kase) do
      has_other_charges.save
      has_other_charges
    end

    let(:partner_other_charge) { OtherCharge.create(ownership_type: OwnershipType::PARTNER.to_s) }

    context 'when other charge is required' do
      before { allow(kase).to receive(:require_partner_other_charge?).and_return(true) }

      it 'returns the other charge' do
        expect(kase.partner_other_charge).to eq(partner_other_charge)
      end
    end

    context 'when other charges are not required' do
      before { allow(kase).to receive(:require_partner_other_charge?).and_return(false) }

      it 'returns nil' do
        expect(kase.partner_other_charge).to be_nil
      end
    end
  end

  describe '#require_client_other_charge_in_progress?' do
    subject(:require_client_other_charge_in_progress?) { has_other_charges.require_client_other_charge_in_progress? }

    context 'when the application is non-means tested' do
      before do
        allow(crime_application).to receive(:non_means_tested?).and_return(true)
      end

      it { is_expected.to be false }
    end

    context 'when the case type is `either_way`' do
      let(:case_type) { CaseType::EITHER_WAY.to_s }

      it { is_expected.to be true }
    end

    context 'when the case type is `indictable`' do
      let(:case_type) { CaseType::INDICTABLE.to_s }

      it { is_expected.to be true }
    end

    context 'when the case type is `already_in_crown_court`' do
      let(:case_type) { CaseType::ALREADY_IN_CROWN_COURT.to_s }

      it { is_expected.to be true }
    end

    context 'when the case type is `summary_only`' do
      let(:case_type) { CaseType::SUMMARY_ONLY.to_s }

      it { is_expected.to be false }
    end

    context 'when the case type is `committal`' do
      let(:case_type) { CaseType::COMMITTAL.to_s }

      it { is_expected.to be false }
    end

    context 'when the case type is `appeal_to_crown_court`' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT.to_s }

      it { is_expected.to be false }
    end

    context 'when the case type is `appeal_to_crown_court_with_changes`' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT_WITH_CHANGES.to_s }

      it { is_expected.to be false }
    end

    context 'when the case type is nil' do
      let(:case_type) { nil }

      it { is_expected.to be false }
    end
  end

  describe '#require_client_other_charge?' do
    subject(:require_client_other_charge?) { has_other_charges.require_client_other_charge? }

    context 'when the other charge question is relevant' do
      before { allow(has_other_charges).to receive(:require_client_other_charge_in_progress?).and_return(true) }

      context 'and `client_other_charge_in_progress` is `yes`' do
        before { has_other_charges.client_other_charge_in_progress = 'yes' }

        it { is_expected.to be true }
      end

      context 'and `client_other_charge_in_progress` is `no`' do
        before { has_other_charges.client_other_charge_in_progress = 'no' }

        it { is_expected.to be false }
      end
    end

    context 'when the other charge question is not relevant' do
      before { allow(has_other_charges).to receive(:require_client_other_charge_in_progress?).and_return(false) }

      it { is_expected.to be false }
    end
  end

  describe '#require_partner_other_charge_in_progress?' do
    subject(:require_partner_other_charge_in_progress?) { has_other_charges.require_partner_other_charge_in_progress? }

    context 'when the application is non-means tested' do
      before do
        allow(crime_application).to receive(:non_means_tested?).and_return(true)
      end

      it { is_expected.to be false }
    end

    context 'when the case type is `either_way`' do
      let(:case_type) { CaseType::EITHER_WAY.to_s }

      context 'and the partner is a victim' do
        let(:involvement_in_case) { PartnerInvolvementType::VICTIM.to_s }

        context 'and the partner does not have a conflict of interest' do
          let(:conflict_of_interest) { 'no' }

          it { is_expected.to be true }
        end

        context 'and the partner has a conflict of interest' do
          let(:conflict_of_interest) { 'yes' }

          it { is_expected.to be false }
        end
      end

      context 'and the partner is a prosecution witness' do
        let(:involvement_in_case) { PartnerInvolvementType::PROSECUTION_WITNESS.to_s }

        context 'and the partner does not have a conflict of interest' do
          let(:conflict_of_interest) { 'no' }

          it { is_expected.to be true }
        end

        context 'and the partner has a conflict of interest' do
          let(:conflict_of_interest) { 'yes' }

          it { is_expected.to be false }
        end
      end

      context 'and the partner is a codefendant' do
        let(:involvement_in_case) { PartnerInvolvementType::CODEFENDANT.to_s }

        context 'and the partner does not have a conflict of interest' do
          let(:conflict_of_interest) { 'no' }

          it { is_expected.to be true }
        end

        context 'and the partner has a conflict of interest' do
          let(:conflict_of_interest) { 'yes' }

          it { is_expected.to be false }
        end
      end

      context 'and the partner is not involved' do
        let(:involvement_in_case) { PartnerInvolvementType::NONE.to_s }

        it { is_expected.to be false }
      end
    end

    context 'when the case type is `indictable`' do
      let(:case_type) { CaseType::INDICTABLE.to_s }

      context 'and the partner is a victim' do
        let(:involvement_in_case) { PartnerInvolvementType::VICTIM.to_s }

        context 'and the partner does not have a conflict of interest' do
          let(:conflict_of_interest) { 'no' }

          it { is_expected.to be true }
        end

        context 'and the partner has a conflict of interest' do
          let(:conflict_of_interest) { 'yes' }

          it { is_expected.to be false }
        end
      end

      context 'and the partner is a prosecution witness' do
        let(:involvement_in_case) { PartnerInvolvementType::PROSECUTION_WITNESS.to_s }

        context 'and the partner does not have a conflict of interest' do
          let(:conflict_of_interest) { 'no' }

          it { is_expected.to be true }
        end

        context 'and the partner has a conflict of interest' do
          let(:conflict_of_interest) { 'yes' }

          it { is_expected.to be false }
        end
      end

      context 'and the partner is a codefendant' do
        let(:involvement_in_case) { PartnerInvolvementType::CODEFENDANT.to_s }

        context 'and the partner does not have a conflict of interest' do
          let(:conflict_of_interest) { 'no' }

          it { is_expected.to be true }
        end

        context 'and the partner has a conflict of interest' do
          let(:conflict_of_interest) { 'yes' }

          it { is_expected.to be false }
        end
      end

      context 'and the partner is not involved' do
        let(:involvement_in_case) { PartnerInvolvementType::NONE.to_s }

        it { is_expected.to be false }
      end
    end

    context 'when the case type is `already_in_crown_court`' do
      let(:case_type) { CaseType::ALREADY_IN_CROWN_COURT.to_s }

      context 'and the partner is a victim' do
        let(:involvement_in_case) { PartnerInvolvementType::VICTIM.to_s }

        context 'and the partner does not have a conflict of interest' do
          let(:conflict_of_interest) { 'no' }

          it { is_expected.to be true }
        end

        context 'and the partner has a conflict of interest' do
          let(:conflict_of_interest) { 'yes' }

          it { is_expected.to be false }
        end
      end

      context 'and the partner is a prosecution witness' do
        let(:involvement_in_case) { PartnerInvolvementType::PROSECUTION_WITNESS.to_s }

        context 'and the partner does not have a conflict of interest' do
          let(:conflict_of_interest) { 'no' }

          it { is_expected.to be true }
        end

        context 'and the partner has a conflict of interest' do
          let(:conflict_of_interest) { 'yes' }

          it { is_expected.to be false }
        end
      end

      context 'and the partner is a codefendant' do
        let(:involvement_in_case) { PartnerInvolvementType::CODEFENDANT.to_s }

        context 'and the partner does not have a conflict of interest' do
          let(:conflict_of_interest) { 'no' }

          it { is_expected.to be true }
        end

        context 'and the partner has a conflict of interest' do
          let(:conflict_of_interest) { 'yes' }

          it { is_expected.to be false }
        end
      end

      context 'and the partner is not involved' do
        let(:involvement_in_case) { PartnerInvolvementType::NONE.to_s }

        it { is_expected.to be false }
      end
    end

    context 'when the case type is `summary_only`' do
      let(:case_type) { CaseType::SUMMARY_ONLY.to_s }

      it { is_expected.to be false }
    end

    context 'when the case type is `committal`' do
      let(:case_type) { CaseType::COMMITTAL.to_s }

      it { is_expected.to be false }
    end

    context 'when the case type is `appeal_to_crown_court`' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT.to_s }

      it { is_expected.to be false }
    end

    context 'when the case type is `appeal_to_crown_court_with_changes`' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT_WITH_CHANGES.to_s }

      it { is_expected.to be false }
    end

    context 'when the case type is nil' do
      let(:case_type) { nil }

      it { is_expected.to be false }
    end
  end

  describe '#require_partner_other_charge?' do
    subject(:require_partner_other_charge?) { has_other_charges.require_partner_other_charge? }

    context 'when the other charge question is relevant' do
      before { allow(has_other_charges).to receive(:require_partner_other_charge_in_progress?).and_return(true) }

      context 'and `partner_other_charge_in_progress` is `yes`' do
        before { has_other_charges.partner_other_charge_in_progress = 'yes' }

        it { is_expected.to be true }
      end

      context 'and `partner_other_charge_in_progress` is `no`' do
        before { has_other_charges.partner_other_charge_in_progress = 'no' }

        it { is_expected.to be false }
      end
    end

    context 'when the other charge question is not relevant' do
      before { allow(has_other_charges).to receive(:require_partner_other_charge_in_progress?).and_return(false) }

      it { is_expected.to be false }
    end
  end
end
