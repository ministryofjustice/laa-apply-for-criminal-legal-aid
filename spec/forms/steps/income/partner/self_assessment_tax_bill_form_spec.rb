require 'rails_helper'

RSpec.describe Steps::Income::Partner::SelfAssessmentTaxBillForm do
  it_behaves_like 'a Self Assessment question form', :partner
end
