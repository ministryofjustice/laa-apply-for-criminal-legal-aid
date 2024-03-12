require 'rails_helper'

RSpec.describe Steps::Capital::InvestmentTypeController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::InvestmentTypeForm,
                  Decisions::CapitalDecisionTree
end
