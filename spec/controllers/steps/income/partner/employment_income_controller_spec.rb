require 'rails_helper'

RSpec.describe Steps::Income::Partner::EmploymentIncomeController, type: :controller do
  it_behaves_like 'a generic step controller',
                  Steps::Income::Partner::EmploymentIncomeForm, Decisions::IncomeDecisionTree
end
