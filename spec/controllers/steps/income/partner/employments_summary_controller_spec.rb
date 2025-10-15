require 'rails_helper'

RSpec.describe Steps::Income::Partner::EmploymentsSummaryController, type: :controller do
  include_context 'current provider with active office'

  let(:existing_case) do
    CrimeApplication.create(office_code: office_code, partner_employments: partner_employments,
                            applicant: Applicant.new)
  end

  context 'when employments present' do
    let(:partner_employments) { [Employment.new(ownership_type: OwnershipType::PARTNER.to_s)] }

    it_behaves_like 'a generic step controller',
                    Steps::Income::Partner::EmploymentsSummaryForm, Decisions::IncomeDecisionTree
  end

  context 'when employments empty' do
    let(:partner_employments) { [] }

    describe '#edit' do
      it 'redirects to the `employment_status` page' do
        get :edit, params: { id: existing_case }

        expect(response).to redirect_to(edit_steps_income_partner_employment_status_path(existing_case))
      end
    end
  end
end
