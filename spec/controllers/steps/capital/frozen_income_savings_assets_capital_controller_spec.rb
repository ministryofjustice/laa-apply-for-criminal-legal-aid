require 'rails_helper'

RSpec.describe Steps::Capital::FrozenIncomeSavingsAssetsCapitalController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::FrozenIncomeSavingsAssetsForm,
                  Decisions::CapitalDecisionTree
end
