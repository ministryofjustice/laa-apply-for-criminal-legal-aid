require 'rails_helper'

RSpec.describe Steps::Case::IojController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Case::IojForm, Decisions::CaseDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Case::IojForm
end
