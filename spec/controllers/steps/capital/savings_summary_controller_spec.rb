require 'rails_helper'

RSpec.describe Steps::Capital::SavingsSummaryController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::SavingsSummaryForm,
                  Decisions::CapitalDecisionTree
end
