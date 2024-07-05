require 'rails_helper'

RSpec.describe Steps::Income::BusinessEmployeesController, type: :controller do
  it_behaves_like 'a business resource step controller', Steps::Income::BusinessEmployeesForm
end
