require 'rails_helper'

RSpec.describe Summary::Components::Offence, type: :component do
  subject(:component) { render_summary_component(described_class.new(record:)) }

  let(:record) { instance_double(Charge, complete?: true, to_param: 'OFF123', **attributes) }

  let(:crime_application) { instance_double(CrimeApplication, id: 'APP123') }

  let(:attributes) do
    { offence_name: 'Common assault', offence_dates: offence_dates, offence_class: 'C' }
  end

  let(:date1) { Date.new(2023, 3, 28) }
  let(:date2) { Date.new(2023, 12, 18) }

  let(:offence_dates) do
    [[date1, date2], [date2, nil]]
  end

  before { component }

  describe 'actions' do
    context 'when show_record_actions set to false' do
      it 'show the "Edit" change link' do
        expect(page).to have_link(
          'Edit',
          href: '/applications/APP123/steps/case/charges-summary',
          exact_text: 'Edit Offence'
        )
      end
    end

    context 'when show_record_actions true' do
      subject(:component) { render_summary_component(described_class.new(record: record, show_record_actions: true)) }

      describe 'change link' do
        it 'show the correct change link' do
          expect(page).to have_link(
            'Change',
            href: '/applications/APP123/steps/case/charges/OFF123',
            exact_text: 'Change Offence'
          )
        end
      end

      describe 'remove link' do
        it 'show the correct remove link' do
          expect(page).to have_link(
            'Remove',
            href: '/applications/APP123/steps/case/charges/OFF123/confirm-destroy',
            exact_text: 'Remove Offence'
          )
        end
      end
    end
  end

  describe 'answers' do
    it 'renders as summary list' do
      expect(page).to have_summary_row(
        'Type',
        'Common assault'
      )
      expect(page).to have_summary_row(
        'Class',
        'C'
      )
      expect(page).to have_summary_row(
        'Date',
        '28 March 2023 – 18 December 202318 December 2023'
      )
    end

    context 'when answers are missing' do
      let(:attributes) do
        { offence_name: nil, offence_dates: [], offence_class: nil }
      end

      it 'renders as summary list with the correct absence_answer' do
        expect(page).to have_summary_row(
          'Type',
          ''
        )
        expect(page).to have_summary_row(
          'Class',
          'Not determined'
        )
        expect(page).to have_summary_row(
          'Date',
          ''
        )
      end
    end
  end

  describe 'card heading' do
    subject(:heading) do
      page.first('h2.govuk-summary-card__title').text
    end

    it { is_expected.to eq 'Offence' }
  end
end
