require 'rails_helper'

RSpec.describe Steps::DWP::CannotCheckDWPStatusController, type: :controller do
  it_behaves_like 'a no-op advance step controller', :cannot_check_dwp_status, Decisions::DWPDecisionTree
end
