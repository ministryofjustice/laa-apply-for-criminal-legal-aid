require 'rails_helper'

RSpec.describe Steps::Partner::SameAddressController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Partner::SameAddressForm, Decisions::PartnerDecisionTree
end
