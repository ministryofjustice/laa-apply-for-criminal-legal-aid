require 'rails_helper'

RSpec.describe Steps::Case::DateStampController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Case::DateStampForm, Decisions::CaseDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Case::DateStampForm
end
