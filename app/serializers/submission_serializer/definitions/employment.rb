module SubmissionSerializer
  module Definitions
    class Employment < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.employer_name employer_name
          json.job_title job_title
          json.has_no_deductions has_no_deductions
          json.amount amount_before_type_cast
          json.frequency frequency.respond_to?(:value) ? frequency.to_s : frequency
          json.ownership_type ownership_type
          json.metadata metadata
          json.address address
          json.deductions Definitions::Deduction.generate(deductions.complete)
        end
      end
    end
  end
end
