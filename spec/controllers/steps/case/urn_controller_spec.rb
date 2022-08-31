require 'rails_helper'

RSpec.describe Steps::Case::UrnController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Case::UrnForm, Decisions::CaseDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Case::UrnForm
end
