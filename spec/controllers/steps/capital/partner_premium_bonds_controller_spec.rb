require 'rails_helper'

RSpec.describe Steps::Capital::PartnerPremiumBondsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::PartnerPremiumBondsForm,
                  Decisions::CapitalDecisionTree
end
