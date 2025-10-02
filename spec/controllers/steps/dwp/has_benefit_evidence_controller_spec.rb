require 'rails_helper'

RSpec.describe Steps::DWP::HasBenefitEvidenceController, type: :controller do
  include_context 'current provider with active office'

  let(:applicant) { Applicant.new }
  let(:partner) { Partner.new }
  let(:partner_detail) { PartnerDetail.new(involvement_in_case: 'victim') }

  let(:existing_case) do
    CrimeApplication.create(partner:,
                            office_code:,
                            partner_detail:,
                            applicant:)
  end

  it_behaves_like 'a step that can be drafted', Steps::DWP::HasBenefitEvidenceForm

  context 'when benefit check is on applicant' do
    let(:partner_detail) { PartnerDetail.new(involvement_in_case: 'none') }
    let(:applicant) { Applicant.new(benefit_type: 'none') }
    let(:partner) { Partner.new(benefit_type: 'none') }

    it_behaves_like 'a generic step controller', Steps::DWP::HasBenefitEvidenceForm, Decisions::DWPDecisionTree
  end

  context 'when benefit check is on partner' do
    let(:partner_detail) { PartnerDetail.new(involvement_in_case: 'none') }
    let(:applicant) { Applicant.new(benefit_type: 'none') }
    let(:partner) { Partner.new(benefit_type: 'universal_credit') }

    it_behaves_like 'a generic step controller', Steps::DWP::HasBenefitEvidencePartnerForm, Decisions::DWPDecisionTree
  end
end
