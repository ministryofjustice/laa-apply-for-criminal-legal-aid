# 3. Use draft submission JSON for the application review page

Date: 2026-05-01

## Status

Accepted

## Context

Before submitting an application, providers are shown a review page where they can check all the information entered before confirming and sending. This page needs to present a complete summary of the application.

The earlier approach rendered this page directly from the ActiveRecord model objects — the same models used by the individual form steps throughout the journey. While this was straightforward to implement initially, it created several problems:

- **Logic divergence** — the review page and the submitted application could show different data. The serializer that produced the submission JSON applied its own rules about which fields to include, but the review page applied different rules through its presenters. Over time these could diverge, meaning a user might confirm information on the review page that did not match what was actually submitted.
- **Duplicated rendering logic** — viewing a submitted application (fetched back from the datastore) required a separate rendering path from the review page, even though both were showing the same conceptual thing.
- **Complexity in presenters** — presenters had to replicate decisions about which fields were relevant in a given application state, decisions that were also made in the serializer.

## Decision

The review page will render from the **draft submission**, not from the ActiveRecord models directly.

`CrimeApplication#draft_submission` serializes the application to JSON using `SubmissionSerializer::Application` (the same serializer used to produce the payload sent to the datastore), then deserializes it into an `Adapters::Structs::CrimeApplication` struct. The review page presenter (`Summary::HtmlPresenter`) receives this struct, not the ActiveRecord record.

```ruby
# ReviewController
def set_presenter
  @presenter = Summary::HtmlPresenter.new(
    crime_application: current_crime_application.draft_submission
  )
end

# CrimeApplication model
def draft_submission
  Adapters::Structs::CrimeApplication.new(draft_submission_as_json)
end

def draft_submission_as_json
  draft = SubmissionSerializer::Application.new(self).to_builder
  draft.set!('status', ApplicationStatus::IN_PROGRESS.to_s)
  draft.attributes!.as_json
end
```

The same `HtmlPresenter` and summary section components are also used to display completed applications fetched from the datastore, since those are already struct-based representations of the submitted JSON.

## Consequences

**Benefits:**

- **What you see is what gets submitted** — the review page shows exactly the data that will be sent to the datastore. Providers confirm based on the actual submission payload, not an approximation of it.
- **Single rendering path** — draft applications on the review page and completed applications in the dashboard are rendered by the same presenter operating on the same struct interface. Changes to the presentation logic apply consistently to both.
- **Serializer as single source of truth** — decisions about which fields are included in a submission live in one place (the serializer). The review page inherits those decisions automatically rather than having to replicate them.
- **Presenters stay simple** — because the struct already reflects only the fields that are relevant for submission (nil or absent values are excluded), presenters do not need their own conditional logic to decide what to display. This is complementary to the dynamic relevance pattern described in [ADR 0004](0004-dynamic-relevance-for-attribute-visibility.md), where model methods return nil for irrelevant attributes — the serializer naturally omits those nil values, and the presenter simply renders what is present.

**Trade-offs:**

- **Serialization on every page load** — the review page triggers a full serialization of the application on each request.
