require 'rails_helper'

RSpec.describe DataTable::HeaderRowComponent, type: :component do
  let(:sorting) do
    double(
      sortable_columns: %w[applicant_name created_at],
      sort_by: 'applicant_name',
      sort_direction: 'ascending',
      reverse_direction: 'descending'
    )
  end

  let(:filter) { nil }

  describe '.new' do
    it 'renders a tr element with the proper class' do
      render_inline(described_class.new(sorting:, filter:)) do |row|
        row.with_cell(colname: 'applicant_name')
      end

      expect(page).to have_css('tr.govuk-table__row')
    end

    it 'renders the sortable table caption before the tr' do
      render_inline(described_class.new(sorting:, filter:)) do |row|
        row.with_cell(colname: 'applicant_name')
      end

      expect(page).to have_css('caption span.govuk-visually-hidden',
                               text: 'Column headers with buttons are sortable.')
    end

    it 'renders cells as th elements' do
      render_inline(described_class.new(sorting:, filter:)) do |row|
        row.with_cell(colname: 'applicant_name')
        row.with_cell(colname: 'created_at')
      end

      expect(page).to have_css('th', count: 2)
      expect(page).to have_text('Name')
      expect(page).to have_text('Start date')
    end

    it 'renders sortable cells as links' do
      render_inline(described_class.new(sorting:, filter:)) do |row|
        row.with_cell(colname: 'applicant_name')
      end

      expect(page).to have_link(text: 'Name')
    end

    it 'passes sorting context to cells' do
      render_inline(described_class.new(sorting:, filter:)) do |row|
        row.with_cell(colname: 'applicant_name')
      end

      expect(page).to have_css('th[aria-sort="ascending"]')
    end

    context 'when filter is provided' do
      let(:filter) do
        double(params: { search_text: 'test' })
      end

      it 'passes filter context to cells' do
        render_inline(described_class.new(sorting:, filter:)) do |row|
          row.with_cell(colname: 'applicant_name')
        end

        expect(page).to have_link(text: 'Name')
      end
    end

    context 'with multiple cells' do
      it 'renders all cells in order' do
        render_inline(described_class.new(sorting:, filter:)) do |row|
          row.with_cell(colname: 'applicant_name', text: 'Client')
          row.with_cell(colname: 'created_at', text: 'Date Created')
          row.with_cell(colname: 'reference', text: 'Reference')
        end

        within('tr') do
          expect(page.all('th').map(&:text)).to eq(['Client', 'Date Created', 'Reference'])
        end
      end
    end
  end
end
