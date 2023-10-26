require 'rails_helper'

RSpec.describe Steps::Income::ManageWithoutIncomeController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::ManageWithoutIncomeForm, Decisions::IncomeDecisionTree
end
