require 'rails_helper'

RSpec.describe Steps::Income::Client::SelfAssessmentTaxBillPaymentController, type: :controller do
  it_behaves_like 'a generic step controller',
                  Steps::Income::Client::SelfAssessmentTaxBillPaymentForm, Decisions::IncomeDecisionTree
end
