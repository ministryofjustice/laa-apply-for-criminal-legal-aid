require 'rails_helper'

RSpec.describe Steps::Income::PartnerEmploymentStatusController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::PartnerEmploymentStatusForm, Decisions::IncomeDecisionTree
end
