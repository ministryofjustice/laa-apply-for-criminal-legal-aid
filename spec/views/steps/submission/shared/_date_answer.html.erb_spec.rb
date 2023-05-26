require 'rails_helper'

describe 'Rendering a summary row of type `DateAnswer`' do
  let(:answer) do
    Summary::Components::DateAnswer.new(
      :date_of_birth, Date.new(2008, 11, 22), change_path: '/edit', i18n_opts: i18n_opts
    )
  end

  let(:i18n_opts) { {} }

  before do
    render answer, editable: true
  end

  # No need to test again the editable state or the change link,
  # as we tested it in `value_answer` and all these partials behave the same
  # because they render a common partial, where that logic resides.

  it 'renders the expected row' do
    assert_select 'div.govuk-summary-list__row', 1 do
      assert_select 'dt.govuk-summary-list__key', text: 'Date of birth'
      assert_select 'dd.govuk-summary-list__value', text: '22 Nov 2008'
      assert_select 'dd.govuk-summary-list__actions a', text: 'Change Date of birth'
    end
  end

  describe 'with an answer with a datetime format' do
    let(:i18n_opts) { { format: :datetime } }

    it 'renders the expected row' do
      assert_select 'div.govuk-summary-list__row', 1 do
        assert_select 'dd.govuk-summary-list__value', text: '22 November 2008 12:00am'
      end
    end
  end
end
