require 'rails_helper'

RSpec.describe Steps::Case::FirstCourtHearingController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Case::FirstCourtHearingForm, Decisions::CaseDecisionTree
end
