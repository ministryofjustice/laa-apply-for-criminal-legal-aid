module Adapters
  class JsonApplication < BaseApplication
    ApplicantStruct = Struct.new(:first_name, :last_name, keyword_init: true)

    def submitted_at
      DateTime.iso8601(self['submitted_at'])
    end

    def applicant
      ApplicantStruct.new(
        first_name: dig('client_details', 'applicant', 'first_name'),
        last_name: dig('client_details', 'applicant', 'last_name'),
      )
    end
  end
end
