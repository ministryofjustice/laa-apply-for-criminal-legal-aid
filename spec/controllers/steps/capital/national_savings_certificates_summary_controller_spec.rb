require 'rails_helper'

RSpec.describe Steps::Capital::NationalSavingsCertificatesSummaryController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::NationalSavingsCertificatesSummaryForm,
                  Decisions::CapitalDecisionTree
end
