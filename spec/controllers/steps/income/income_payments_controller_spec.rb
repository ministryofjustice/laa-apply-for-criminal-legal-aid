require 'rails_helper'

RSpec.describe Steps::Income::IncomePaymentsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::IncomePaymentsForm,
                  Decisions::IncomeDecisionTree
end
