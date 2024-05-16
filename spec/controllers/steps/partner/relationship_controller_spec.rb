require 'rails_helper'

RSpec.describe Steps::Partner::RelationshipController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Partner::RelationshipForm, Decisions::PartnerDecisionTree
end
