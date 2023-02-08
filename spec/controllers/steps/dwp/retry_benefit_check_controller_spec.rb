require 'rails_helper'

RSpec.describe Steps::DWP::RetryBenefitCheckController, type: :controller do
  it_behaves_like 'a no-op advance step controller', :retry_benefit_check, Decisions::DWPDecisionTree
end
