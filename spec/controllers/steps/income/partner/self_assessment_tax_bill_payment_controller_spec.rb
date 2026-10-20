require 'rails_helper'

RSpec.describe Steps::Income::Partner::SelfAssessmentTaxBillPaymentController, type: :controller do
  it_behaves_like 'a Self Assessment payment controller',
                  :partner, :partner, Steps::Income::Partner::SelfAssessmentTaxBillPaymentForm
end
