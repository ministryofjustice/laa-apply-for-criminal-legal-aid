'use strict';

function GAEvents($window) {
  this.$window = $window
  this.$document = $window.document

  this.$radioFormClass = '.govuk-radios__item input[type="radio"]'
  this.$checkboxClass = '.govuk-checkboxes__item input[type="checkbox"]'
  this.$dateFormClass = '.govuk-date-input input[type="text"]'
  this.$linkClass = '.ga-pageLink'
}

GAEvents.prototype.init = function () {
  // don't bind anything if the GA object isn't defined
  if (typeof this.$window.gtag === 'undefined') {
    return
  }

  this.trackRadioForms()
  this.trackCheckboxes()
  this.trackDateForms()
  this.trackLinks()
}

GAEvents.prototype.trackRadioForms = function () {
  const $el = this.$document.querySelector(this.$radioFormClass)
  if (!$el) { return }

  const self = this,
        $form = $el.closest('form')

  $form.addEventListener('submit', function (e) {
    let eventDataArray = self.getRadioChoiceData($form)
    self.processEventData($form, eventDataArray)
  })
}

GAEvents.prototype.trackCheckboxes = function () {
  const $el = this.$document.querySelector(this.$checkboxClass)
  if (!$el) { return }

  const self = this,
        $form = $el.closest('form')

  $form.addEventListener('submit', function (e) {
    let eventDataArray = self.getCheckboxFormData($form)
    self.processEventData($form, eventDataArray)
  });
}

GAEvents.prototype.trackDateForms = function () {
  const $el = this.$document.querySelector(this.$dateFormClass)
  if (!$el) { return }

  const self = this,
        $form = $el.closest('form')

  $form.addEventListener('submit', function (e) {
    let eventDataArray = self.getDateYearData($form)
    self.processEventData($form, eventDataArray)
  });
}

GAEvents.prototype.trackLinks = function () {
  const self = this,
        $links = this.$document.querySelectorAll(this.$linkClass)

  $links.forEach(function (link, n) {
    link.addEventListener('click', function (e) {
      let eventData = self.getLinkData(e.target);
      let options = {
        actionType: 'link',
        actionValue: e.target
      }

      self.sendAnalyticsEvent(eventData, options)
    })
  })
}

GAEvents.prototype.getRadioChoiceData = function($form) {
  let $selectedRadios = $form.querySelectorAll('input[type="radio"]:checked'),
      eventDataArray = []

  $selectedRadios.forEach(function (radio, n) {
    let $radio = radio,
        eventData

    eventData = {
      hitType: 'event',
      eventAction: 'choose',
      eventCategory: $radio.getAttribute('name'),
      eventLabel: $radio.value
    }

    eventDataArray.push(eventData)
  })

  return eventDataArray
}

GAEvents.prototype.getCheckboxFormData = function($form) {
  let $checkedCheckboxes = $form.querySelectorAll('input[type="checkbox"]:checked'),
      eventDataArray = []

  $checkedCheckboxes.forEach(function (checkbox, n) {
    let $checkbox = checkbox,
        eventData

    eventData = {
      hitType: 'event',
      eventAction: 'checkbox',
      eventCategory: $checkbox.getAttribute('name'),
      eventLabel: $checkbox.value
    }

    eventDataArray.push(eventData);
  })

  return eventDataArray;
}

GAEvents.prototype.getDateYearData = function($form) {
  let $dateYears = $form.querySelectorAll('input[type="text"][id$="_1i"]'),
      eventDataArray = []

  $dateYears.forEach(function (date, n) {
    let $year = date,
        eventData

    eventData = {
      hitType: 'event',
      eventAction: 'enter_date',
      eventCategory: $year.getAttribute('name').replace("(1i)", "_yyyy"),
      eventLabel: $year.value
    }

    if ($year.value) {
      eventDataArray.push(eventData);
    }
  })

  return eventDataArray
}

GAEvents.prototype.getLinkData = function($link) {
  return {
    eventAction: 'select_link',
    eventCategory: $link.getAttribute('data-ga-category'),
    eventLabel: $link.getAttribute('data-ga-label')
  }
}

GAEvents.prototype.processEventData = function($form, eventDataArray) {
  if (eventDataArray.length === 0) return;

  let self = this,
      options

  eventDataArray.forEach(function (eventData, n) {
    if (n === eventDataArray.length - 1) {
      options = {
        actionType: 'form',
        actionValue: $form
      }
    }

    self.sendAnalyticsEvent(eventData, options)
  })
}

GAEvents.prototype.sendAnalyticsEvent = function(eventData, options) {
  try {
    this.$window.gtag('event', eventData.eventAction, {
      'event_category': eventData.eventCategory,
      'event_label': eventData.eventLabel
    })
  } catch(e) {}
}

export default GAEvents;
