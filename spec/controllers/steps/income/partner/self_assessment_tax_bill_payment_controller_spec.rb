require 'rails_helper'

RSpec.describe Steps::Income::Partner::SelfAssessmentTaxBillPaymentController, type: :controller do
  it_behaves_like 'a generic step controller',
                  Steps::Income::Partner::SelfAssessmentTaxBillPaymentForm, Decisions::IncomeDecisionTree
end
