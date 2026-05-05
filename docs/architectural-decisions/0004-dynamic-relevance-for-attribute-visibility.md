# 4. Dynamic relevance for attribute visibility

Date: 2026-05-01

## Status

Accepted

## Context

Crime Apply is a multi-step form where earlier answers determine which later questions are asked. This creates a class of attributes that may become irrelevant if a user changes a prior answer — for example, switching case type away from "Appeal to Crown Court" makes all appeal-specific fields irrelevant.

Before this pattern was established, irrelevant data was handled in two main ways:

1. **Form-driven resets** — forms would explicitly nil out dependent fields when a controlling answer changed (e.g. `CaseTypeForm` clearing all appeal fields on case type change).
2. **Presenter/validator conditionals** — the logic for deciding whether an attribute was relevant was duplicated across presenters, serializers, validators, and external service adapters.

Both approaches had significant drawbacks:

- **Data loss** — resetting fields means a user who changes their mind and reverses an earlier answer must re-enter all dependent information.
- **Scattered responsibility** — the rules about which data matters in which state lived in multiple places and could easily diverge.
- **Increased coupling** — adding a new conditional field required changes in forms, presenters, validators, and serializers simultaneously.

## Decision

We will centralise attribute relevance logic in the **model layer**. Each model method for a conditionally relevant attribute guards the call to `super` (the database value) behind a state predicate. When the attribute is not relevant to the current application state, the method returns `nil`; when relevant, it returns the actual persisted value.

```ruby
class Case < ApplicationRecord
  def appeal_lodged_date
    super if appeal_case_type?
  end

  def appeal_financial_circumstances_changed
    super if appeal_original_app_submitted?
  end

  def appeal_maat_id
    super if original_application_reference_required?
  end

  private

  def appeal_case_type?
    return false unless case_type
    CaseType.new(case_type).appeal?
  end

  def appeal_original_app_submitted?
    appeal_original_app_submitted == 'yes'
  end

  def original_application_reference_required?
    appeal_financial_circumstances_changed == 'no'
  end
end
```

The database value is preserved at all times. Downstream consumers (presenters, serializers, validators, external service adapters) treat a `nil` return as "this field is not present" without needing to know why.

## Consequences

**Benefits:**

- **No data loss** — users can change earlier answers and reverse them without re-entering dependent information.
- **Single source of truth** — the rules for what data is relevant in a given state live exclusively in the model. Changing the rules requires updating one place.
- **Simpler consumers** — presenters, serializers, and validators can treat model output uniformly without conditional logic. A `nil` value simply means "not applicable right now".
- **Safer form handling** — forms no longer need to manage cascading nil-resets, reducing the risk of accidentally clearing data that should be preserved.

**Trade-offs:**

- **Invisible data** — database columns may contain values that are not surfaced through the model. This can be surprising when querying the database directly or writing migrations. The pattern must be understood by developers working on the codebase, however this problem goes once the draft is submitted.
- **Model complexity** — models accrue more methods as more attributes adopt this pattern. Predicate method naming and grouping must be kept clear.
- **Test strategy** — tests should focus on state combination scenarios (e.g. "when case type is appeal and original app was submitted and circumstances changed: no") rather than testing individual predicate methods in isolation, to ensure the full chain of relevance logic is covered.reference
