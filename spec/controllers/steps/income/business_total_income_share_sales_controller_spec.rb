require 'rails_helper'

RSpec.describe Steps::Income::BusinessTotalIncomeShareSalesController, type: :controller do
  it_behaves_like 'a business resource step controller', Steps::Income::BusinessTotalIncomeShareSalesForm
end
