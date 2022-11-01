require 'rails_helper'

RSpec.describe Steps::Case::PassportOnIojController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Case::PassportOnIojForm, Decisions::CaseDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Case::PassportOnIojForm
end
