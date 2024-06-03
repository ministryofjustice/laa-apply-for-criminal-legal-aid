require 'rails_helper'

RSpec.describe Steps::Partner::ConflictController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Partner::ConflictForm, Decisions::PartnerDecisionTree
end
