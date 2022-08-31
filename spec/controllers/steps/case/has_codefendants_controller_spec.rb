require 'rails_helper'

RSpec.describe Steps::Case::HasCodefendantsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Case::HasCodefendantsForm, Decisions::CaseDecisionTree
end
