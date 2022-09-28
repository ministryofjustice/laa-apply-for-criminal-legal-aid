require 'rails_helper'

RSpec.describe Steps::Case::HearingDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Case::HearingDetailsForm, Decisions::CaseDecisionTree
end
