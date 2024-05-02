require 'rails_helper'

RSpec.describe Steps::DWP::BenefitCheckResultController, type: :controller do
  it_behaves_like 'a no-op advance step controller', :benefit_check_result, Decisions::DWPDecisionTree
end
