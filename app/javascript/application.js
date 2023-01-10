// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

// https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#javascript
import { initAll } from 'govuk-frontend'
initAll()

// NOTE: suggestions input component not yet part of GOV.UK frontend
// https://github.com/alphagov/govuk-frontend/pull/2453
import Input from "local/suggestions"

const $inputs = document.querySelectorAll('[data-module="govuk-input"]')
if ($inputs) {
  for (let i = 0; i < $inputs.length; i++) {
    new Input($inputs[i]).init()
  }
}

import accessibleAutocomplete from 'accessible-autocomplete'

const $acElements = document.querySelectorAll('[data-module="accessible-autocomplete"]')
if ($acElements) {
  for (let i = 0; i < $acElements.length; i++) {
    accessibleAutocomplete.enhanceSelectElement({
      selectElement: $acElements[i],
      defaultValue: ''
    })
  }
}
