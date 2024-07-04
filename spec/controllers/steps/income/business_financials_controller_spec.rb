require 'rails_helper'

RSpec.describe Steps::Income::BusinessFinancialsController, type: :controller do
  it_behaves_like 'a business resource step controller', Steps::Income::BusinessFinancialsForm
end
