require 'rails_helper'

RSpec.describe Steps::Client::AppealFinancialCircumstancesController, type: :controller do
  it_behaves_like 'a generic step controller',
                  Steps::Client::AppealFinancialCircumstancesForm, Decisions::ClientDecisionTree

  it_behaves_like 'a step disallowed for change in financial circumstances applications'
end
