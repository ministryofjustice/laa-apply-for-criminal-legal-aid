RSpec.describe Steps::Evidence::AdditionalInformationController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Evidence::AdditionalInformationForm,
                  Decisions::EvidenceDecisionTree
end
