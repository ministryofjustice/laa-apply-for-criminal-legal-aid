require 'rails_helper'

RSpec.describe Steps::Capital::InvestmentsSummaryController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::InvestmentsSummaryForm,
                  Decisions::CapitalDecisionTree
end
