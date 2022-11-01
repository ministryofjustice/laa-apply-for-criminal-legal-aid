require 'rails_helper'

describe 'Rendering a summary row of type `FreeTextAnswer`' do
  let(:answer) do
    Summary::Components::FreeTextAnswer.new(
      :first_name, 'John', change_path: '/edit'
    )
  end

  before do
    render answer, editable: true
  end

  # No need to test again the editable state or the change link,
  # as we tested it in `value_answer` and all these partials behave the same
  # because they render a common partial, where that logic resides.

  it 'renders the expected row' do
    assert_select 'div.govuk-summary-list__row', 1 do
      assert_select 'dt.govuk-summary-list__key', text: 'First name'
      assert_select 'dd.govuk-summary-list__value', text: 'John'
      assert_select 'dd.govuk-summary-list__actions a', text: 'Change First name'
    end
  end
end
