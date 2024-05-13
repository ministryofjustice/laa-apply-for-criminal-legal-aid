require 'rails_helper'

RSpec.describe Steps::Income::Client::EmployerDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::Client::EmployerDetailsForm, Decisions::IncomeDecisionTree
end
