require 'rails_helper'

RSpec.describe Steps::Client::RelationshipStatusController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Client::RelationshipStatusForm, Decisions::ClientDecisionTree
end
