module Steps
  module UsualPropertyDetailsStep
    extend ActiveSupport::Concern

    def edit
      @form_object = form_name.build(
        current_crime_application
      )
    end

    def update
      update_and_advance(form_name, as: :usual_property_details)
    end

    private

    def additional_permitted_params
      [:action]
    end
  end
end
