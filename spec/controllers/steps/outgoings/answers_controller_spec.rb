require 'rails_helper'

RSpec.describe Steps::Outgoings::AnswersController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Shared::NoOpForm,
                  Decisions::OutgoingsDecisionTree
end
