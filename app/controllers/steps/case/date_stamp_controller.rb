module Steps
  module Case
    class DateStampController < Steps::CaseStepController
      def show
        # A charge needs creating ahead of hitting the charges
        # edit page, but the show date stamp page is not a
        # form and so this needs to happen here as we are
        # outside of the decision tree.

        # Requires a rethink of the architecture.

        @charge = current_crime_application.case.charges.create!
      end
    end
  end
end
