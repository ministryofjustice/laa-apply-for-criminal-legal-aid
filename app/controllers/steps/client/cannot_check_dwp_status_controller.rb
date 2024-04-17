module Steps
  module Client
    class CannotCheckDWPStatusController < Steps::ClientStepController
      include Steps::NoOpAdvanceStep

      private

      def advance_as
        :cannot_check_dwp_status
      end
    end
  end
end
