require 'rails_helper'

RSpec.describe Steps::Partner::InvolvementController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Partner::InvolvementForm, Decisions::PartnerDecisionTree
end
