require 'rails_helper'

RSpec.describe Steps::Income::LostJobInCustodyController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::LostJobInCustodyForm, Decisions::IncomeDecisionTree
end
