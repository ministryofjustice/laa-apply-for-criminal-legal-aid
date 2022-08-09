require 'rails_helper'

RSpec.describe Steps::Address::ResultsController, type: :controller do
  it_behaves_like 'an address step controller', Steps::Address::ResultsForm, Decisions::AddressDecisionTree
end
