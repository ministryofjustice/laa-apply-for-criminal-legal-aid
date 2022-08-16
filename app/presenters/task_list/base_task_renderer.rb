module TaskList
  class BaseTaskRenderer
    include ActionView::Helpers::UrlHelper

    attr_reader :view, :name

    delegate :tag, to: :view
    delegate :t!, to: I18n

    def initialize(view, name:)
      @view = view
      @name = name
    end

    # :nocov:
    def self.render(view, **kwargs)
      new(view, **kwargs).render
    end

    def render
      raise 'implement in subclasses'
    end
    # :nocov:

    private

    def tag_id
      [name, 'status'].join('-')
    end
  end
end
