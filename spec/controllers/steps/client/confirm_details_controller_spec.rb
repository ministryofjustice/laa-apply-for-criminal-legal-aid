require 'rails_helper'

RSpec.describe Steps::Client::ConfirmDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Client::ConfirmDetailsForm, Decisions::ClientDecisionTree
end
