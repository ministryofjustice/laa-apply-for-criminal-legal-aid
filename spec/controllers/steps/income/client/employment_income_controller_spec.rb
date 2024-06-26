require 'rails_helper'

RSpec.describe Steps::Income::Client::EmploymentIncomeController, type: :controller do
  it_behaves_like 'a generic step controller',
                  Steps::Income::Client::EmploymentIncomeForm, Decisions::IncomeDecisionTree
end
