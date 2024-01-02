module Steps
  module Client
    class DateStampController < Steps::ClientStepController
      include Steps::NoOpAdvanceStep

      private

      def advance_as
        :date_stamp
      end
    end
  end
end
