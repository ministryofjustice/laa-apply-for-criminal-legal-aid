module SubmissionSerializer
  module Definitions
    class Person < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.first_name first_name
          json.last_name last_name
          json.date_of_birth date_of_birth

          json.home_address Definitions::Address.generate(home_address)
        end
      end
    end
  end
end
