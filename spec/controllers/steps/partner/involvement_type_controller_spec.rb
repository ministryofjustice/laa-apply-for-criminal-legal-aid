require 'rails_helper'

RSpec.describe Steps::Partner::InvolvementTypeController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Partner::InvolvementTypeForm, Decisions::PartnerDecisionTree
end
