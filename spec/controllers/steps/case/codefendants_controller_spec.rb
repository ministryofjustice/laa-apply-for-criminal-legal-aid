require 'rails_helper'

RSpec.describe Steps::Case::CodefendantsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Case::CodefendantsForm, Decisions::CaseDecisionTree
end
