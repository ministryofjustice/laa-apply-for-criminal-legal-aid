module DataTable
  class HeaderCellComponent < GovukComponent::Base
    def initialize(colname:, scope:, colspan:, sorting:, filter:, numeric:, text:, classes: []) # rubocop:disable Metrics/ParameterLists
      @colname = colname
      @text = text
      @colspan = colspan
      @numeric = numeric
      @scope = scope
      @sorting = sorting
      @filter = filter

      super(classes: classes, html_attributes: {})
    end

    attr_reader :sorting, :filter, :colname, :colspan, :scope, :numeric, :text

    def call
      tag.th(**html_attributes) do
        cell_content
      end
    end

    private

    def cell_content
      return name unless sortable?

      button_to(name, "##{colname}", params: sorted_params, method: http_method)
    end

    def http_method
      return :post if request.method == 'POST'

      :get
    end

    def default_classes
      class_names(
        "#{brand}-table__header",
        "#{brand}-table__header--numeric" => numeric
      )
    end

    def default_attributes
      {
        class: default_classes,
        id: colname,
        colspan: colspan,
        scope: scope,
        aria: { sort: sort_state }
      }
    end

    def name
      return text if text

      sanitize(I18n.t(colname, scope: 'table_headings')) if colname.present?
    end

    def sortable?
      sorting.sortable_columns.include?(colname)
    end

    def sorted_params
      request_params = request.query_parameters || {}
      request_params.merge(filter ? { filter: filter.params } : {}).merge(sorting_params)
    end

    def sorting_params
      {
        sorting: {
          sort_by: colname,
          sort_direction: sorting.reverse_direction
        }
      }
    end

    #
    # returns 'ascending', 'descending' or 'none' depending on
    # the columns sort state if sortable.
    #
    def sort_state
      return nil unless sortable?
      return 'none' unless active?

      sorting.sort_direction
    end

    def active?
      colname == sorting.sort_by
    end
  end
end
