require 'rails_helper'

RSpec.describe Steps::Income::ArmedForcesController, type: :controller do
  context 'when subject is client' do
    it_behaves_like 'a generic step controller', Steps::Income::ArmedForcesForm, Decisions::IncomeDecisionTree do
      let(:base_params) { { subject: 'client' } }
    end
  end

  context 'when subject is partner' do
    let(:existing_case) do
      CrimeApplication.create!(
        applicant: Applicant.new,
        partner: Partner.new,
        partner_detail: PartnerDetail.new(involvement_in_case: 'none')
      )
    end

    it_behaves_like 'a generic step controller', Steps::Income::ArmedForcesForm, Decisions::IncomeDecisionTree do
      let(:base_params) { { subject: 'partner' } }
    end
  end
end
