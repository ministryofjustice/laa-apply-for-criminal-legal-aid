module Steps
  module Contact
    class PostcodeLookupController < Steps::ContactStepController
      def edit
        @form_object = PostcodeLookupForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(PostcodeLookupForm, as: :postcode_lookup)
      end
    end
  end
end
