require 'rails_helper'

RSpec.describe Steps::Client::DetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Client::DetailsForm, Decisions::ClientDecisionTree
end
