module Evidence
  module Rules
    class BadRuleDefinition < Rule
      include Evidence::RuleDsl

      archived true
      group :workplace

      client do
        'Predicate should evaluate to true or false!'
      end

      partner do
        'Predicate should evaluate to true or false!'
      end

      other do
        'Predicate should evaluate to true or false!'
      end
    end
  end
end
