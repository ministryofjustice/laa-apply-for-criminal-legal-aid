require 'rails_helper'

RSpec.describe Steps::Circumstances::PreCifcReasonController, type: :controller do
  include_context 'current provider with active office'
  let(:existing_case) do
    CrimeApplication.create!(
      office_code: office_code,
      application_type: ApplicationType::CHANGE_IN_FINANCIAL_CIRCUMSTANCES
    )
  end

  it_behaves_like 'a generic step controller',
                  Steps::Circumstances::PreCifcReasonForm, Decisions::CircumstancesDecisionTree

  it_behaves_like 'a step disallowed for non change in financial circumstances applications'
end
