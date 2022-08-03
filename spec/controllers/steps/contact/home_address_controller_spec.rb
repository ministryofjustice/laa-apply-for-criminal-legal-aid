require 'rails_helper'

RSpec.describe Steps::Contact::HomeAddressController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Contact::HomeAddressForm, Decisions::ContactDecisionTree
end
