require 'rails_helper'

RSpec.describe Steps::Income::FrozenIncomeSavingsAssetsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::FrozenIncomeSavingsAssetsForm,
                  Decisions::IncomeDecisionTree
end
