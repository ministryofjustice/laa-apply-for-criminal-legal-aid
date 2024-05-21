require 'rails_helper'

RSpec.describe Decisions::PartnerDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      partner_detail:,
    )
  end

  let(:partner_detail) do
    instance_double(
      PartnerDetail,
      relationship_to_partner: nil,
      involvement_in_case: nil,
      conflict_of_interest: nil,
      same_address_as_client: nil,
    )
  end

  let(:form_object) { double('FormObject') }

  before do
    allow(form_object).to receive(:crime_application).and_return(crime_application)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is partner relationship' do
    let(:step_name) { :relationship }

    it { is_expected.to have_destination(:details, :edit, id: crime_application) }
  end

  context 'when the step is partner details' do
    let(:step_name) { :details }

    it { is_expected.to have_destination(:nino, :edit, id: crime_application) }
  end

  context 'when the step is partner nino' do
    let(:step_name) { :nino }

    it { is_expected.to have_destination(:involvement, :edit, id: crime_application) }
  end

  context 'when the step is partner involvement' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :involvement }

    let(:partner_detail) { double(PartnerDetail, involvement_in_case:) }
    let(:not_means_tested) { nil }

    before do
      allow(form_object).to receive(:involvement_in_case).and_return(involvement_in_case)
      allow(crime_application).to receive_messages(not_means_tested?: not_means_tested)
    end

    context 'when partner is a co-defendant' do
      let(:involvement_in_case) { PartnerInvolvementType::CODEFENDANT }

      it { is_expected.to have_destination(:conflict, :edit, id: crime_application) }
    end

    context 'when partner is not involved' do
      let(:involvement_in_case) { PartnerInvolvementType::NONE }

      it { is_expected.to have_destination(:same_address, :edit, id: crime_application) }
    end

    context 'without means tested application' do
      let(:not_means_tested) { true }

      context 'when partner is a victim' do
        let(:involvement_in_case) { PartnerInvolvementType::VICTIM }

        it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
      end

      context 'when partner is a prosecution witness' do
        let(:involvement_in_case) { PartnerInvolvementType::PROSECUTION_WITNESS }

        it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
      end
    end

    context 'with means tested application' do
      let(:not_means_tested) { false }

      context 'when partner is a victim' do
        let(:involvement_in_case) { PartnerInvolvementType::VICTIM }

        it { is_expected.to have_destination('/steps/dwp/benefit_type', :edit, id: crime_application) }
      end

      context 'when partner is a prosecution witness' do
        let(:involvement_in_case) { PartnerInvolvementType::PROSECUTION_WITNESS }

        it { is_expected.to have_destination('/steps/dwp/benefit_type', :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is partner conflict of interest' do
    let(:form_object) { double('FormObject') }
    let(:partner_detail) { double(PartnerDetail, conflict_of_interest:) }
    let(:step_name) { :conflict }

    before do
      allow(form_object).to receive(:conflict_of_interest).and_return(conflict_of_interest)
      allow(crime_application).to receive_messages(not_means_tested?: not_means_tested)
    end

    context 'without means tested application' do
      let(:not_means_tested) { true }

      context 'when partner has conflict of interest' do
        let(:conflict_of_interest) { YesNoAnswer::YES }

        it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
      end

      context 'when partner does not have conflict of interest' do
        let(:conflict_of_interest) { YesNoAnswer::NO }

        it { is_expected.to have_destination(:same_address, :edit, id: crime_application) }
      end
    end

    context 'with means tested application' do
      let(:not_means_tested) { false }

      context 'when partner has conflict of interest' do
        let(:conflict_of_interest) { YesNoAnswer::YES }

        it { is_expected.to have_destination('/steps/dwp/benefit_type', :edit, id: crime_application) }
      end

      context 'when partner does not have conflict of interest' do
        let(:conflict_of_interest) { YesNoAnswer::NO }

        it { is_expected.to have_destination(:same_address, :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is partner same address as client' do
    let(:form_object) { double('FormObject', partner_id: partner.id) }
    let(:step_name) { :same_address }

    let(:partner_detail) { double(PartnerDetail, same_address_as_client:) }
    let(:partner) { instance_double(Partner, id: SecureRandom.uuid.to_s) }

    before do
      allow(form_object).to receive(:same_address_as_client).and_return(same_address_as_client)
      allow(crime_application).to receive_messages(
        not_means_tested?: not_means_tested,
        partner: partner,
      )
      allow(HomeAddress).to receive(:find_or_create_by).and_return(partner)
    end

    context 'without means tested application' do
      let(:not_means_tested) { true }

      context 'when same address as client' do
        let(:same_address_as_client) { YesNoAnswer::YES }

        it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
      end

      context 'when partner does not have same address as client' do
        let(:same_address_as_client) { YesNoAnswer::NO }

        it { is_expected.to have_destination('/steps/address/lookup', :edit, id: crime_application) }
      end
    end

    context 'with means tested application' do
      let(:not_means_tested) { false }

      context 'when same address as client' do
        let(:same_address_as_client) { YesNoAnswer::YES }

        it { is_expected.to have_destination('/steps/dwp/benefit_type', :edit, id: crime_application) }
      end

      context 'when partner does not have same address as client' do
        let(:same_address_as_client) { YesNoAnswer::NO }

        it { is_expected.to have_destination('/steps/address/lookup', :edit, id: crime_application) }
      end
    end
  end
end
