module Steps
  module Submission
    class ConfirmationController < Steps::SubmissionStepController
      include DatastoreApplicationConsumer

      skip_before_action :update_navigation_stack

      before_action :check_crime_application_presence,
                    :present_crime_application, only: [:show]

      def show; end
    end
  end
end
