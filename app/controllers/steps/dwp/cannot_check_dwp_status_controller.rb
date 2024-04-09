module Steps
  module DWP
    class CannotCheckDWPStatusController < Steps::DWPStepController
      include Steps::NoOpAdvanceStep

      private

      def advance_as
        :cannot_check_dwp_status
      end
    end
  end
end
