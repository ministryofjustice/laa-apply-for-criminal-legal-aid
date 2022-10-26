require 'rails_helper'

RSpec.describe Steps::Dwp::ConfirmDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Dwp::ConfirmDetailsForm, Decisions::DwpDecisionTree
end
