require 'rails_helper'

RSpec.describe Steps::Case::IsClientRemandedController, type: :controller do
  include_context 'current provider with active office'
  it_behaves_like 'a generic step controller', Steps::Case::IsClientRemandedForm, Decisions::CaseDecisionTree
end
