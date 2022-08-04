require 'rails_helper'

RSpec.describe Steps::Client::ContactDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Client::ContactDetailsForm, Decisions::ClientDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Client::ContactDetailsForm
end
