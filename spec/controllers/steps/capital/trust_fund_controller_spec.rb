require 'rails_helper'

RSpec.describe Steps::Capital::TrustFundController, type: :controller do
  include_context 'current provider with active office'
  it_behaves_like 'a generic step controller', Steps::Capital::TrustFundForm,
                  Decisions::CapitalDecisionTree
end
