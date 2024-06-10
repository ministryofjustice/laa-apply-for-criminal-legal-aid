require 'rails_helper'

RSpec.describe Steps::Capital::PartnerTrustFundController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::PartnerTrustFundForm,
                  Decisions::CapitalDecisionTree
end
