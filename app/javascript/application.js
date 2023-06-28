// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

// https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#javascript
import { initAll } from 'govuk-frontend'
initAll()

// Cookie banner
// https://design-system.service.gov.uk/components/cookie-banner/
import CookieBanner from "local/cookie-banner"
const $cookieBanner = document.querySelector('[data-module="govuk-cookie-banner"]')
if ($cookieBanner) {
  new CookieBanner($cookieBanner).init()
}

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

// Keep focus on the sub-navigation
// This improves accessibility when navigating with
// keyboard or screen readers
import SubNavigation from 'local/subnavigation'
const $subNavigation = document.querySelector('nav.moj-sub-navigation')
new SubNavigation($subNavigation).init()

// Avoid flickering header menu on small screens
// Refer to `stylesheets/local/custom.scss`
const $headerNavigation = document.querySelector('ul.app-header-menu-hidden-on-load')
if ($headerNavigation) {
  $headerNavigation.classList.remove("app-header-menu-hidden-on-load")
}

// Allow window.print(), otherwise blocked by CSP
import PrintAction from "local/print-action"
const $elements = document.querySelectorAll('[data-module="print"]')
for (let i = 0; i < $elements.length; i++) {
  new PrintAction($elements[i]).init()
}

// Google analytics additional tracking
// Keep this at the bottom of this file
import GAEvents from "local/ga-events"
new GAEvents(window).init()
