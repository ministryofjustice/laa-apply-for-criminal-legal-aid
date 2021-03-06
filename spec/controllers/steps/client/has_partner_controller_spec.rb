require 'rails_helper'

RSpec.describe Steps::Client::HasPartnerController, type: :controller do
  it_behaves_like 'a starting point step controller'
  it_behaves_like 'a generic step controller', Steps::Client::HasPartnerForm, Decisions::ClientDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Client::HasPartnerForm
end
