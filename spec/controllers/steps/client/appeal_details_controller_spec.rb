require 'rails_helper'

RSpec.describe Steps::Client::AppealDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Client::AppealDetailsForm, Decisions::ClientDecisionTree
end
