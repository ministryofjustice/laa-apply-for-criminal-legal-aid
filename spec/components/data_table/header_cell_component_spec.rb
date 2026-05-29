require 'rails_helper'

RSpec.describe DataTable::HeaderCellComponent, type: :component do
  let(:sorting) do
    instance_double(
      'Sorting',
      sortable_columns: %w[applicant_name created_at],
      sort_by: 'applicant_name',
      sort_direction: 'ascending',
      reverse_direction: 'descending'
    )
  end

  let(:filter) { nil }

  describe '.new' do
    context 'when column is sortable' do
      before do
        render_inline(described_class.new(
                        colname: 'applicant_name',
                        scope: 'col',
                        colspan: 1,
                        sorting: sorting,
                        filter: filter,
                        numeric: false,
                        text: nil
                      ))
      end

      it 'renders a button for the column header' do
        expect(page).to have_button(text: 'Name')
      end

      it 'sets an aria-label on the sort button' do
        expect(page).to have_css('button[aria-label="sort by Name"]')
      end

      it 'sets aria-sort to ascending for the active column' do
        expect(page).to have_css('th[aria-sort="ascending"]')
      end

      context 'when the column is not currently sorted' do
        let(:sorting) do
          instance_double(
            'Sorting',
            sortable_columns: %w[applicant_name created_at],
            sort_by: 'created_at',
            sort_direction: 'descending',
            reverse_direction: 'ascending'
          )
        end

        it 'sets aria-sort to none' do
          expect(page).to have_css('th[aria-sort="none"]')
        end
      end
    end

    context 'when column is not sortable' do
      let(:sorting) do
        instance_double(
          'Sorting',
          sortable_columns: [],
          sort_by: nil,
          sort_direction: nil,
          reverse_direction: nil
        )
      end

      before do
        render_inline(described_class.new(
                        colname: 'action',
                        scope: 'col',
                        colspan: 1,
                        sorting: sorting,
                        filter: filter,
                        numeric: false,
                        text: nil
                      ))
      end

      it 'renders text instead of a button' do
        expect(page).to have_no_button
        expect(page).to have_text('Action')
      end

      it 'does not set aria-sort' do
        expect(page).to have_no_css('th[aria-sort]')
      end

      it 'does not set a sort aria-label' do
        expect(page).to have_no_css('button[aria-label^="sort by "]')
      end
    end

    context 'when custom text is provided' do
      before do
        render_inline(described_class.new(
                        colname: 'applicant_name',
                        scope: 'col',
                        colspan: 1,
                        sorting: sorting,
                        filter: filter,
                        numeric: false,
                        text: 'Client Name'
                      ))
      end

      it 'uses the custom text instead of i18n lookup' do
        expect(page).to have_button(text: 'Client Name')
      end
    end

    context 'when numeric is true' do
      before do
        render_inline(described_class.new(
                        colname: 'applicant_name',
                        scope: 'col',
                        colspan: 1,
                        sorting: sorting,
                        filter: filter,
                        numeric: true,
                        text: nil
                      ))
      end

      it 'applies the numeric class' do
        expect(page).to have_css('th.govuk-table__header--numeric')
      end
    end

    context 'when colspan is greater than 1' do
      before do
        render_inline(described_class.new(
                        colname: 'applicant_name',
                        scope: 'col',
                        colspan: 2,
                        sorting: sorting,
                        filter: filter,
                        numeric: false,
                        text: nil
                      ))
      end

      it 'sets the colspan attribute' do
        expect(page).to have_css('th[colspan="2"]')
      end
    end
  end
end
