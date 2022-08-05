require 'rails_helper'

RSpec.describe Steps::Address::DetailsController, type: :controller do
  it_behaves_like 'an address step controller', Steps::Address::DetailsForm, Decisions::AddressDecisionTree
end
