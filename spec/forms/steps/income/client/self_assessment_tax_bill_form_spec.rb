require 'rails_helper'

RSpec.describe Steps::Income::Client::SelfAssessmentTaxBillForm do
  it_behaves_like 'a Self Assessment question form', :applicant
end
