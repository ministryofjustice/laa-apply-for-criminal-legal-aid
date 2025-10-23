# :nocov:
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

      # Main class
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

              # A rule can apply to 0, 1 or more personas. The personas available are:
              #   - client
              #   - partner
              #   - other
              #
              # # 'predicate' is a lambda method executed and expected to evaluate to true or false.
              #
              # An evidence upload prompt is displayed if the predicate is true.

              client do |_crime_application|
                # Predicate must return true or false
                true
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

      # Generate corresponding spec
      spec_filename = "#{timestamp}_#{class_name}_spec".underscore

      create_file "spec/services/evidence/rules/#{spec_filename}.rb", <<~RUBY
        require 'rails_helper'

        RSpec.describe Evidence::Rules::#{class_name} do
          subject { described_class.new(crime_application) }

          # A double may not always be appropriate for testing,
          # consider using real objects
          let(:crime_application) do
            instance_double(
              CrimeApplication,
            )
          end

          it { expect(described_class.key).to eq :#{rule_key} }
          it { expect(described_class.group).to eq :income }
          it { expect(described_class.archived).to be false }
          it { expect(described_class.active?).to be true }

          describe '.client' do
            subject { described_class.new(crime_application).client_predicate }

            it { expect(subject).to be true }
          end

          describe '.partner' do
            subject { described_class.new(crime_application).partner_predicate }

            it { expect(subject).to be false }
          end

          describe '.other' do
            subject { described_class.new(crime_application).other_predicate }

            it { expect(subject).to be false }
          end

          describe '#to_h' do
            let(:expected_hash) do
              {
                id: '#{class_name}',
                group: :income,
                ruleset: nil,
                key: :#{rule_key},
                run: {
                  client: {
                    result: true,
                    prompt: ['Add evidence.yml entry for rule #{class_name}: client'],
                  },
                  partner: {
                    result: false,
                    prompt: [],
                  },
                  other: {
                    result: false,
                    prompt: [],
                  },
                }
              }
            end

            it { expect(subject.to_h).to eq expected_hash }
          end
        end
      RUBY
    end
  end
end
# :nocov:
