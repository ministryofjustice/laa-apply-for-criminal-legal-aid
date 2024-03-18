require 'rails_helper'

RSpec.describe Steps::Capital::TrustFundController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::TrustFundForm,
                  Decisions::CapitalDecisionTree
end
