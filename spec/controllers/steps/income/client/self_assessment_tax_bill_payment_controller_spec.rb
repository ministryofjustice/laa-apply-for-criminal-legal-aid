require 'rails_helper'

RSpec.describe Steps::Income::Client::SelfAssessmentTaxBillPaymentController, type: :controller do
  it_behaves_like 'a Self Assessment payment controller',
                  :client, :applicant, Steps::Income::Client::SelfAssessmentTaxBillPaymentForm
end
