require 'rails_helper'

RSpec.describe Steps::Address::LookupController, type: :controller do
  it_behaves_like 'an address step controller', Steps::Address::LookupForm, Decisions::AddressDecisionTree
end
