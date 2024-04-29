module Evidence
  module Rules
    class ExampleOfOther < Rule
      include Evidence::RuleDsl

      key :other_example

      # NOTE: :none group adds output to the various 'other' sections
      group :none

      client do |_crime_application|
        true
      end

      partner do |_crime_application|
        true
      end

      other do |_crime_application|
        true
      end
    end
  end
end
