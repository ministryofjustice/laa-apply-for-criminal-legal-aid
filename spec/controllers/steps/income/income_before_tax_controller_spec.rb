require 'rails_helper'

RSpec.describe Steps::Income::IncomeBeforeTaxController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::IncomeBeforeTaxForm, Decisions::IncomeDecisionTree
end
