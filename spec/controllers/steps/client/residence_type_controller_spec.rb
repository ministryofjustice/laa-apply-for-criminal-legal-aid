require 'rails_helper'

RSpec.describe Steps::Client::ResidenceTypeController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Client::ResidenceTypeForm, Decisions::ClientDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Client::ResidenceTypeForm
end
