require 'rails_helper'

RSpec.describe Steps::Client::BenefitCheckResultController, type: :controller do
  it_behaves_like 'a no-op advance step controller', :benefit_check_result, Decisions::ClientDecisionTree
end
