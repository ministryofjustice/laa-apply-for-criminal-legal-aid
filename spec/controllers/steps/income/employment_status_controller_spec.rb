require 'rails_helper'

RSpec.describe Steps::Income::EmploymentStatusController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::EmploymentStatusForm, Decisions::IncomeDecisionTree
end
