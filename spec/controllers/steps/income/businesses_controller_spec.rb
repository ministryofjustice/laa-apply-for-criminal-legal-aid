require 'rails_helper'

RSpec.describe Steps::Income::BusinessesController, type: :controller do
  it_behaves_like 'a business resource step controller', Steps::Income::BusinessesForm
end
