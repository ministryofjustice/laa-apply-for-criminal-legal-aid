require 'rails_helper'

RSpec.describe Steps::Capital::HasNationalSavingsCertificatesController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::HasNationalSavingsCertificatesForm,
                  Decisions::CapitalDecisionTree
end
