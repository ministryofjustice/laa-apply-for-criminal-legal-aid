require 'rails_helper'

RSpec.describe Steps::Case::OtherChargeInProgressController, type: :controller do
  let(:existing_case) do
    CrimeApplication.create!(
      applicant: Applicant.new,
      partner: Partner.new,
      partner_detail: PartnerDetail.new(involvement_in_case: 'none'),
      case: Case.new(case_type: CaseType::EITHER_WAY)
    )
  end

  context 'when subject is client' do
    it_behaves_like 'a generic step controller', Steps::Case::OtherChargeInProgressForm, Decisions::CaseDecisionTree do
      let(:base_params) { { subject: 'client' } }
    end
  end

  context 'when subject is partner' do
    it_behaves_like 'a generic step controller', Steps::Case::OtherChargeInProgressForm, Decisions::CaseDecisionTree do
      let(:base_params) { { subject: 'partner' } }
    end
  end
end
