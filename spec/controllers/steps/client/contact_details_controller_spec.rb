require 'rails_helper'

RSpec.describe Steps::Client::ContactDetailsController, type: :controller do
  let(:office_code) { '1A123B' }
  let(:current_office) { Office.new(office_code: office_code, active?: true, contingent_liability?: false) }
  let(:provider) { Provider.new(office_codes: [office_code], selected_office_code: office_code) }

  before do
    allow(controller).to receive(:current_provider).and_return(provider)
  end

  it_behaves_like 'a generic step controller', Steps::Client::ContactDetailsForm, Decisions::ClientDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Client::ContactDetailsForm
end
