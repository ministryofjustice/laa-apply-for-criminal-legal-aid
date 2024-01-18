require 'rails_helper'

RSpec.describe Steps::Case::HasCaseConcludedController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Case::HasCaseConcludedForm, Decisions::CaseDecisionTree
end