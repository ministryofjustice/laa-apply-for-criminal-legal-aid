require 'rails_helper'

RSpec.describe Steps::Outgoings::PartnerIncomeTaxRateController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Outgoings::PartnerIncomeTaxRateForm,
                  Decisions::OutgoingsDecisionTree
end
