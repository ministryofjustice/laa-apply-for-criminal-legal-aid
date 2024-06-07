require 'rails_helper'

RSpec.describe Steps::DWP::CannotCheckDWPStatusController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::DWP::CannotCheckDWPStatusForm, Decisions::DWPDecisionTree
end
