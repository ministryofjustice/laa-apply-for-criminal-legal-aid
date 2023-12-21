require 'rails_helper'

RSpec.describe Steps::Outgoings::IncomeTaxRateController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Outgoings::IncomeTaxRateForm,
                  Decisions::OutgoingsDecisionTree
end
