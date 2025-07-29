// https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#javascript
import { initAll } from 'govuk-frontend'
initAll()

// Cookie banner -- Script name is obfuscated to avoid browsers blocking it
// https://design-system.service.gov.uk/components/cookie-banner/
import Cbc from "./local/cbc"
const $cookieBanner = document.querySelector('[data-module="govuk-cookie-banner"]')
if ($cookieBanner) {
  new Cbc($cookieBanner).init()
}

// Dropzone component initialisation and configuration
import DropzoneCfg from "./local/dropzone-cfg"
new DropzoneCfg({
  dropzoneContainer: "form#dz-evidence-upload-form",
  feedbackContainer: "div.app-multi-file__uploaded-files"
}).init()

// NOTE: suggestions input component not yet part of GOV.UK frontend
// https://github.com/alphagov/govuk-frontend/pull/2453
import Input from "./local/suggestions"
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
import SubNavigation from './local/subnavigation'
const $subNavigation = document.querySelector('nav.moj-sub-navigation')
new SubNavigation($subNavigation).init()

// Avoid flickering header menu on small screens
// Refer to `stylesheets/local/custom.scss`
const $headerNavigation = document.querySelector('ul.app-header-menu-hidden-on-load')
if ($headerNavigation) {
  $headerNavigation.classList.remove("app-header-menu-hidden-on-load")
}

// Allow window.print(), otherwise blocked by CSP
import PrintAction from "./local/print-action"
const $elements = document.querySelectorAll('[data-module="print"]')
for (let i = 0; i < $elements.length; i++) {
  new PrintAction($elements[i]).init()
}

// Duplicate "main" submit and place it hidden higher than others
// in the DOM hierarchy, so pressing `enter` key picks this one
// Used in forms with secondary submit actions in between
import MultiActionForm from "./local/multi-action-form"
const $forms = document.querySelectorAll('form[data-module="multi-action-form"]')
for (let i = 0; i < $forms.length; i++) {
  new MultiActionForm($forms[i]).init()
}

// Disabled for time being, see CRIMAPP-1877
// Google analytics additional tracking
// Keep this at the bottom of this file
// import GAEvents from "./local/ga-events"
// new GAEvents(window).init()
