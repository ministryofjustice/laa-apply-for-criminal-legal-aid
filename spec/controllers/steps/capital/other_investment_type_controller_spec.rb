require 'rails_helper'

RSpec.describe Steps::Capital::OtherInvestmentTypeController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::OtherInvestmentTypeForm,
                  Decisions::CapitalDecisionTree
end
