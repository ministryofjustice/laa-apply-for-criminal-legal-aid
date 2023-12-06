require 'rails_helper'

RSpec.describe Steps::Income::PaymentsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::PaymentsForm,
                  Decisions::IncomeDecisionTree
end