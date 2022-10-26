require 'rails_helper'

RSpec.describe Steps::Dwp::ConfirmResultController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Dwp::ConfirmResultForm, Decisions::DwpDecisionTree
end
