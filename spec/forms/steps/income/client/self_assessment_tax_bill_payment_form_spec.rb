require 'rails_helper'

RSpec.describe Steps::Income::Client::SelfAssessmentTaxBillPaymentForm do
  it_behaves_like 'a Self Assessment payment form', :applicant
end
