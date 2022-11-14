module Steps
  module Submission
    class ConfirmationController < Steps::SubmissionStepController
      # This action is special, as soon we will not have
      # a DB record after the application is submitted.
      # Ensure there is nothing in the view using the DB.
      #
      skip_before_action :check_crime_application_presence,
                         :update_navigation_stack

      def show
        @reference = reference_param
      end

      private

      def reference_param
        params[:reference].to_i
      end
    end
  end
end
