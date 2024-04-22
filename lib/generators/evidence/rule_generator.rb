module Evidence
  class RuleGenerator < Rails::Generators::Base
    class_option :key, type: :string, default: :rule_key_from_confluence
    class_option :class, type: :string, default: nil

    desc 'Creates new Evidence upload Rule in app/services/evidence/rules'
    def create_evidence_rule
      timestamp = DateTime.now.strftime(Evidence::Rule::TIMESTAMP_FORMAT)
      rule_key = options['key']
      class_name = options['class'].blank? ? 'MyRule' : options['class']
      filename = "#{timestamp}_#{class_name}".underscore

      create_file "app/services/evidence/rules/#{filename}.rb", <<~RUBY
        module Evidence
          module Rules
            class #{class_name} < Rule
              include Evidence::RuleDsl

              # The rule key is found in confluence, search for 'Evidence upload rules'
              key :#{rule_key}

              # One of :income, :outgoings, :capital or :none
              group :income

              # Archived rules prevent a rule from executing even if set for a historic ruleset
              archived false

              # A rule can apply to 0, 1 or more personas. The personas availble are:
              #   - client
              #   - partner
              #   - other
              #
              # # 'predicate' is a lambda method executed and expected to return true or false.
              #
              # An evidence upload prompt is displayed if the predicate returns true.

              client do |_crime_application|
                # Predicate must return true or false
                false
              end

              partner do |_crime_application|
                # Predicate must return true or false
                false
              end

              other do |_crime_application|
                # Predicate must return true or false
                false
              end
            end
          end
        end
      RUBY
    end
  end
end
