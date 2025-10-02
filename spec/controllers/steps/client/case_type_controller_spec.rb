require 'rails_helper'

RSpec.describe Steps::Client::CaseTypeController, type: :controller do
  include_context 'current provider with active office'

  it_behaves_like 'a generic step controller', Steps::Client::CaseTypeForm, Decisions::ClientDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Client::CaseTypeForm
end
