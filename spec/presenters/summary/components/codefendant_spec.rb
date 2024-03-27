require 'rails_helper'

RSpec.describe Summary::Components::Codefendant, type: :component do
  subject(:component) { render_inline(described_class.new(record:)) }

  let(:record) { instance_double(Codefendant, complete?: true, to_param: 'OFF123', case: kase, **attributes) }

  let(:kase) { instance_double(Case, crime_application_id: 'APP123') }
  let(:attributes) { { first_name: 'Joe', last_name: 'Blogs', conflict_of_interest: 'yes' } }

  before { component }

  describe 'actions' do
    context 'when show_record_actions set to false' do
      it 'show the "Edit" change link' do
        expect(page).to have_link(
          'Edit',
          href: '/applications/APP123/steps/case/codefendants#codefendant_0',
          exact_text: 'Edit Co-defendant'
        )
      end
    end

    context 'when show_record_actions true' do
      subject(:component) { render_inline(described_class.new(record: record, show_record_actions: true)) }

      describe 'change link' do
        it 'show the correct change link' do
          expect(page).to have_link(
            'Change',
            href: '/applications/APP123/steps/case/codefendants#codefendant_0',
            exact_text: 'Change Co-defendant'
          )
        end
      end

      describe 'remove link' do
        it 'show the correct remove link' do
          expect(page).to have_link(
            'Remove',
            href: '/applications/APP123/steps/case/codefendants#codefendant_0',
            exact_text: 'Remove Co-defendant'
          )
        end
      end
    end
  end

  describe 'answers' do
    it 'renders as summary list' do
      expect(page).to have_summary_row('First name', 'Joe')
      expect(page).to have_summary_row('Last name', 'Blogs')
      expect(page).to have_summary_row('Conflict of interest?', 'Yes')
    end

    context 'when answers are missing' do
      let(:attributes) do
        { first_name: nil, last_name: nil, conflict_of_interest: nil }
      end

      it 'renders as summary list with the correct absence_answer' do
        expect(page).to have_summary_row('First name', '')
        expect(page).to have_summary_row('Last name', '')
        expect(page).to have_summary_row('Conflict of interest?', '')
      end
    end
  end

  describe 'card heading' do
    subject(:heading) do
      page.first('h2.govuk-summary-card__title').text
    end

    it { is_expected.to eq 'Co-defendant' }
  end
end
