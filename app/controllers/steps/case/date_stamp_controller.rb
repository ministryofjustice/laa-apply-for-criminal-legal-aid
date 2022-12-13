module Steps
  module Case
    class DateStampController < Steps::CaseStepController
      include Steps::NoOpAdvanceStep

      private

      def advance_as
        :date_stamp
      end
    end
  end
end
