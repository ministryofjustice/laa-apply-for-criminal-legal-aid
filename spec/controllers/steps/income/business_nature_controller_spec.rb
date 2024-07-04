require 'rails_helper'

RSpec.describe Steps::Income::BusinessNatureController, type: :controller do
  it_behaves_like 'a business resource step controller', Steps::Income::BusinessNatureForm
end
