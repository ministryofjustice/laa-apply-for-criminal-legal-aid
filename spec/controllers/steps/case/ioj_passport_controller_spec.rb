require 'rails_helper'

RSpec.describe Steps::Case::IojPassportController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Case::IojPassportForm, Decisions::CaseDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Case::IojPassportForm
end
