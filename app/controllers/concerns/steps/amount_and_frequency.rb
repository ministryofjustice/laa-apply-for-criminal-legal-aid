module Steps
  module AmountAndFrequency
    extend ActiveSupport::Concern

    def edit
      @form_object = Steps::Shared::NoOpForm.build(
        current_crime_application
      )
    end

    def update
      update_and_advance(
        Steps::Shared::NoOpForm, as: advance_as
      )
    end

    private

    # :nocov:
    def advance_as
      raise 'implement in controllers using this concern'
    end
    # :nocov:
  end
end

