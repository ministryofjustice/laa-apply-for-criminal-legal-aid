require 'rails_helper'

RSpec.describe Steps::Outgoings::HousingPaymentTypeController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Outgoings::HousingPaymentTypeForm,
                  Decisions::OutgoingsDecisionTree
end
