module Steps
  module Case
    class DateStampController < Steps::CaseStepController
      def show
        @charge = current_crime_application.case.charges.create!
      end
    end
  end
end
