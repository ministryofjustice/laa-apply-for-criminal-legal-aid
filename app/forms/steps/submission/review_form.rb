module Steps
  module Submission
    class ReviewForm < Steps::BaseFormObject
      def persist!
        crime_application.valid?(:submission)
      end
    end
  end
end
