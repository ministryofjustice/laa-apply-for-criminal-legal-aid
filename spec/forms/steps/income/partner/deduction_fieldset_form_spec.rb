require 'rails_helper'

RSpec.describe Steps::Income::Partner::DeductionFieldsetForm do
  it_behaves_like 'a deduction fieldset form', described_class, true
end
