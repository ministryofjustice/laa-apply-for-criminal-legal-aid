'use strict';

function MultiActionForm($form) {
  this.$form = $form
  this.$mainActionSelector = '.govuk-button-group button[data-main-action="true"]'
}

MultiActionForm.prototype.init = function() {
  const $submit = this.$form.querySelector(this.$mainActionSelector)

  if ($submit) {
    let $clonedSubmit = $submit.cloneNode(true)

    // Hide this button completely, including screen-readers
    $clonedSubmit.setAttribute('class', 'govuk-visually-hidden')
    $clonedSubmit.setAttribute('aria-hidden', 'true')
    $clonedSubmit.setAttribute('tabindex', '-1')

    this.$form.prepend($clonedSubmit)
  }
}

export default MultiActionForm
