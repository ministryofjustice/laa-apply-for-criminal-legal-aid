require 'rails_helper'

describe 'Rendering a summary row of type `OffenceAnswer`' do
  let(:answer) do
    Summary::Components::OffenceAnswer.new(
      :offence_details, presented_charge, change_path: '/edit', i18n_opts: { index: 1 }
    )
  end

  let(:presented_charge) do
    double(
      'PresentedCharge',
      offence_name: offence_name,
      offence_class: offence_class,
      offence_dates: [Date.new(2000, 11, 3)],
      complete?: complete,
    )
  end

  let(:complete) { true }
  let(:offence_name) { 'My offence name' }
  let(:offence_class) { 'Offence class' }

  before do
    render answer, editable: true
  end

  # No need to test again the editable state or the change link,
  # as we tested it in `value_answer` and all these partials behave the same
  # because they render a common partial, where that logic resides.

  it 'renders the expected row' do
    assert_select 'div.govuk-summary-list__row', 1 do
      assert_select 'dt.govuk-summary-list__key', text: 'Offence 1'
      assert_select 'dd.govuk-summary-list__value p:nth-of-type(1)', count: 1, text: 'My offence name'
      assert_select 'dd.govuk-summary-list__value p:nth-of-type(2).govuk-caption-m', count: 1, text: 'Offence class'
      assert_select 'dd.govuk-summary-list__value p:nth-of-type(3)', count: 1, text: '3 Nov 2000'
      assert_select 'dd.govuk-summary-list__actions a', text: 'Change Offence 1'
    end
  end

  context 'when the offence has no name' do
    let(:offence_name) { nil }

    it 'shows a placeholder copy' do
      assert_select 'dd.govuk-summary-list__value p:nth-of-type(1)', 'Name not entered'
    end
  end

  context 'when the offence has no class' do
    let(:offence_class) { nil }

    it 'shows a placeholder copy' do
      assert_select 'dd.govuk-summary-list__value p.govuk-caption-m', 'Class not specified'
    end
  end

  context 'when the offence is incomplete' do
    let(:complete) { false }

    it 'shows an incomplete tag' do
      assert_select 'dd.govuk-summary-list__value strong.moj-badge--red', 'Incomplete'
    end
  end
end
