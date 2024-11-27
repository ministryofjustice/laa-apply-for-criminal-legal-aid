module DataTable
  class HeadComponent < GovukComponent::Base
    renders_many :rows, lambda { |classes: []|
      DataTable::HeaderRowComponent.new(sorting: @sorting, filter: @filter, classes: classes)
    }

    def initialize(sorting:, filter: {}, classes: [])
      @sorting = sorting
      @filter = filter

      super(classes: classes, html_attributes: {})
    end

    def call
      tag.thead(**html_attributes) { safe_join(rows) }
    end

    private

    def default_attributes
      { class: "#{brand}-table__head" }
    end
  end
end
