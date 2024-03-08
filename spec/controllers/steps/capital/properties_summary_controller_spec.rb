require 'rails_helper'

RSpec.describe Steps::Capital::PropertiesSummaryController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::PropertiesSummaryForm,
                  Decisions::CapitalDecisionTree
end
