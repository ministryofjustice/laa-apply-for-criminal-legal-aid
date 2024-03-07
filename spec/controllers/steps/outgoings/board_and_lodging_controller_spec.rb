require 'rails_helper'

RSpec.describe Steps::Outgoings::BoardAndLodgingController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Outgoings::BoardAndLodgingForm,
                  Decisions::OutgoingsDecisionTree
end
