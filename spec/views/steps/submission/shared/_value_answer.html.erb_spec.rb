require 'rails_helper'

describe 'Rendering a summary row of type `ValueAnswer`' do
  let(:answer) do
    Summary::Components::ValueAnswer.new(
      :case_type, CaseType::SUMMARY_ONLY, change_path:
    )
  end

  before do
    render answer, editable:
  end

  context 'for editable rows' do
    let(:editable) { true }

    context 'with change link' do
      let(:change_path) { '/edit' }

      it 'renders the expected row' do
        assert_select 'div.govuk-summary-list__row--no-actions', 0

        assert_select 'div.govuk-summary-list__row', 1 do
          assert_select 'dt.govuk-summary-list__key', text: 'Case type'
          assert_select 'dd.govuk-summary-list__value', text: 'Summary only'
          assert_select 'dd.govuk-summary-list__actions a', text: 'Change Case type'
        end
      end
    end

    context 'without change link' do
      let(:change_path) { nil }

      it 'renders the expected row' do
        assert_select 'div.govuk-summary-list__row--no-actions', 1 do
          assert_select 'dt.govuk-summary-list__key', text: 'Case type'
          assert_select 'dd.govuk-summary-list__value', text: 'Summary only'
          assert_select 'dd.govuk-summary-list__actions', 0
        end
      end
    end
  end

  context 'for non-editable rows' do
    let(:editable) { false }

    context 'with change link' do
      let(:change_path) { '/edit' }

      it 'renders the expected row' do
        assert_select 'div.govuk-summary-list__row--no-actions', 1 do
          assert_select 'dt.govuk-summary-list__key', text: 'Case type'
          assert_select 'dd.govuk-summary-list__value', text: 'Summary only'
          assert_select 'dd.govuk-summary-list__actions', 0
        end
      end
    end

    context 'without change link' do
      let(:change_path) { nil }

      it 'renders the expected row' do
        assert_select 'div.govuk-summary-list__row--no-actions', 1 do
          assert_select 'dt.govuk-summary-list__key', text: 'Case type'
          assert_select 'dd.govuk-summary-list__value', text: 'Summary only'
          assert_select 'dd.govuk-summary-list__actions', 0
        end
      end
    end
  end
end
