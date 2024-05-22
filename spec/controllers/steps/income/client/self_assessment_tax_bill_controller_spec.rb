require 'rails_helper'

RSpec.describe Steps::Income::Client::SelfAssessmentTaxBillController, type: :controller do
  it_behaves_like 'a generic step controller',
                  Steps::Income::Client::SelfAssessmentTaxBillForm, Decisions::IncomeDecisionTree
end
