module TaskList
  class BaseRenderer
    include ActionView::Helpers::TagHelper
    include ActionView::Context

    attr_reader :crime_application, :name

    delegate :t!, to: I18n

    def initialize(crime_application, name:)
      @crime_application = crime_application
      @name = name
    end

    # :nocov:
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
