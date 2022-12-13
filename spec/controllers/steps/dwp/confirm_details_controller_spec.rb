require 'rails_helper'

RSpec.describe Steps::DWP::ConfirmDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::DWP::ConfirmDetailsForm, Decisions::DWPDecisionTree
end
