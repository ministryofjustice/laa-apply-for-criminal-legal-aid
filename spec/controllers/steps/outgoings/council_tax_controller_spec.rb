require 'rails_helper'

RSpec.describe Steps::Outgoings::CouncilTaxController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Outgoings::CouncilTaxForm,
                  Decisions::OutgoingsDecisionTree
end
