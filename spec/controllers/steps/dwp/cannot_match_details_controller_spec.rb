require 'rails_helper'

RSpec.describe Steps::DWP::CannotMatchDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::DWP::CannotMatchDetailsForm, Decisions::DWPDecisionTree
end
