require 'rails_helper'

describe 'Rendering a summary row of type `ValueAnswer`' do
  let(:crime_application) { CrimeApplication.new(status:) }

  let(:answer) do
    Summary::Components::ValueAnswer.new(
      :passporting, :yes, change_path:
    )
  end

  before do
    allow(view).to receive(:current_crime_application).and_return(crime_application)
    render answer
  end

  context 'for an `in_progress` application' do
    let(:status) { ApplicationStatus::IN_PROGRESS.to_s }

    context 'with change link' do
      let(:change_path) { '/edit' }

      it 'renders the expected row' do
        assert_select 'div.govuk-summary-list__row--no-actions', 0

        assert_select 'div.govuk-summary-list__row', 1 do
          assert_select 'dt.govuk-summary-list__key', text: 'Passporting benefit'
          assert_select 'dd.govuk-summary-list__value', text: 'Yes'
          assert_select 'dd.govuk-summary-list__actions a', text: 'Change Passporting benefit'
        end
      end
    end

    context 'without change link' do
      let(:change_path) { nil }

      it 'renders the expected row' do
        assert_select 'div.govuk-summary-list__row--no-actions', 1 do
          assert_select 'dt.govuk-summary-list__key', text: 'Passporting benefit'
          assert_select 'dd.govuk-summary-list__value', text: 'Yes'
          assert_select 'dd.govuk-summary-list__actions', 0
        end
      end
    end
  end

  context 'for a `submitted` application' do
    let(:status) { ApplicationStatus::SUBMITTED.to_s }

    context 'with change link' do
      let(:change_path) { '/edit' }

      it 'renders the expected row' do
        assert_select 'div.govuk-summary-list__row--no-actions', 1 do
          assert_select 'dt.govuk-summary-list__key', text: 'Passporting benefit'
          assert_select 'dd.govuk-summary-list__value', text: 'Yes'
          assert_select 'dd.govuk-summary-list__actions', 0
        end
      end
    end

    context 'without change link' do
      let(:change_path) { nil }

      it 'renders the expected row' do
        assert_select 'div.govuk-summary-list__row--no-actions', 1 do
          assert_select 'dt.govuk-summary-list__key', text: 'Passporting benefit'
          assert_select 'dd.govuk-summary-list__value', text: 'Yes'
          assert_select 'dd.govuk-summary-list__actions', 0
        end
      end
    end
  end
end
