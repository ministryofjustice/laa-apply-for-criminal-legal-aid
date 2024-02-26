require 'rails_helper'

RSpec.describe Steps::Capital::PremiumBondsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::PremiumBondsForm,
                  Decisions::CapitalDecisionTree
end
