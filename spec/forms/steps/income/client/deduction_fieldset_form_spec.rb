require 'rails_helper'

RSpec.describe Steps::Income::Client::DeductionFieldsetForm do
  it_behaves_like 'a deduction fieldset form', described_class, false
end
