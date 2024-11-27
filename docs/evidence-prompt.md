# Evidence Prompt

Before application submission the provider must supply uploaded documentary evidence to support the answers given. Which documents to upload is governed by the Evidence Prompt.

## Generating a new rule
```
rails g evidence:rule --key my_key_from_spreadsheet --class ApplicantLivesInOwnHouse2025
```

This will generate a Rule class and a corresponding RSpec test. The `key` should be copied from the source Evidence Triggers speadsheet (see below). The `class` name should be unique and ideally reflect the nature of the rule.


## Validation
At least 1 document should be uploaded if there was evidence required. No data verification is performed - this is the caseworker's job.

## System design

A `Prompt` is initialized with the `CrimeApplication` in its current state. Some 'pre-flight' checks are made as not all applications require evidence upload - for example if the applicant is under 18.

After the pre-flight checks, a `Ruleset` is executed. For new/unsubmitted applications the Ruleset is `Latest`. For returned applications the ruleset is `Hydrated`.

Each `Rule` corresponds to a `key`. Therefore a `key` can have many `Rule` implementations. This is to allow versioning of rules with newer rules taking precedence over older rules in the `Latest` Ruleset. In the `Hydrated` Ruleset, the Rule executed for a given key is persisted in the `CrimeApplication#evidence_prompts` field.

The `key` also acts as a link between the implementation code and the first spreadsheet drawn up by the business analysts. The spreadsheet 'Evidence Triggers' can be found in Google Drive (and/or Confluence). This ensures the business understanding of a Rule and the corresponding code logic have a clear audit trail.

When the `Prompt` is initialized, the `Ruleset` is determined and the individual `Rule` predicates are evaluated in order of `Runner::KEYS`. The order of `Runner::KEYS` determines output order for the result of each group of predicates.

## Groups and Personas

Each Rule can specify a `group` (one of :income, :outgoings, :capital, :none) and a `persona` (one of :client, :partner, :other).

The `group` value controls in which output section/grouping the actual prompt wording will be displayed.

Each persona has a corresponding `predicate`. The predicate must evaluate to `TrueClass` or `FalseClass` (i.e. ruby `true` or `false`). Any `nil` values will be treated as an exception. This is to force evaluation to always be `true` or `false` and not undetermined. That may change in future to allow flexibility.

The output from each `predicate` will determine which `sentence` to show, using the `evidence.yml` translation file as the source for all output.
