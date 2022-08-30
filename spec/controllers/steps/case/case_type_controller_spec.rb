require 'rails_helper'

RSpec.describe Steps::Case::CaseTypeController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Case::CaseTypeForm, Decisions::CaseDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Case::CaseTypeForm
end
