require 'rails_helper'

RSpec.describe Steps::Income::Partner::SelfAssessmentTaxBillController, type: :controller do
  it_behaves_like 'a generic step controller',
                  Steps::Income::Partner::SelfAssessmentTaxBillForm, Decisions::IncomeDecisionTree
end
