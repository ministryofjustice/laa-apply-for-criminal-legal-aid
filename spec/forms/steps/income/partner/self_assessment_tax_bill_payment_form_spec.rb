require 'rails_helper'

RSpec.describe Steps::Income::Partner::SelfAssessmentTaxBillPaymentForm do
  it_behaves_like 'a Self Assessment payment form', :partner
end
