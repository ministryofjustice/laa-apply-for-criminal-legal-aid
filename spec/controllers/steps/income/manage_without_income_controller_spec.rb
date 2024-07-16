require 'rails_helper'

RSpec.describe Steps::Income::ManageWithoutIncomeController, type: :controller do
  before do
    allow_any_instance_of(Applicant).to receive(:under18?).and_return(false)
  end

  it_behaves_like 'a generic step controller', Steps::Income::ManageWithoutIncomeForm, Decisions::IncomeDecisionTree
end
