require 'rails_helper'

RSpec.describe Steps::Client::ConfirmNinoDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Client::ConfirmNinoDetailsForm, Decisions::ClientDecisionTree
end
