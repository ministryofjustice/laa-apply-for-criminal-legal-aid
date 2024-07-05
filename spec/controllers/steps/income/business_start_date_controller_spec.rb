require 'rails_helper'

RSpec.describe Steps::Income::BusinessStartDateController, type: :controller do
  it_behaves_like 'a business resource step controller', Steps::Income::BusinessStartDateForm
end
