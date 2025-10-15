require 'rails_helper'

RSpec.describe Steps::Income::Client::EmploymentIncomeController, type: :controller do
  include_context 'current provider with active office'
  it_behaves_like 'a generic step controller',
                  Steps::Income::Client::EmploymentIncomeForm, Decisions::IncomeDecisionTree
end
