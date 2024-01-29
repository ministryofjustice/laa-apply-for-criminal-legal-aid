require 'rails_helper'

RSpec.describe Steps::Case::IsClientRemandedController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Case::IsClientRemandedForm, Decisions::CaseDecisionTree
end
