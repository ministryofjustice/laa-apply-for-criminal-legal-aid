require 'rails_helper'

RSpec.describe Steps::Case::AppealDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Case::AppealDetailsForm, Decisions::CaseDecisionTree
end
