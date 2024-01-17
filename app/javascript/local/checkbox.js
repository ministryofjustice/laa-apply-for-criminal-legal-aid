'use strict';

function Checkboxes($element) {
  this.$subNavigation = $element
  this.$pageSelector  = '[aria-current="page"]'
}
/**
 * Uncheck exclusive checkboxes
 *
 * Find any checkbox inputs with the same name value and the 'exclusive' behaviour,
 * and uncheck them. This helps prevent someone checking both a regular checkbox and a
 * "None of these" checkbox in the same fieldset.
 *
 * @deprecated Will be made private in v5.0
 * @param {HTMLInputElement} $input - Checkbox input
 */
Checkboxes.prototype.unCheckExclusiveInputs = function ($input) {
  console.log("LOCAL CHECKBOX uncheckExclusive!")
};

/**
 * Click event handler
 *
 * Handle a click within the $module – if the click occurred on a checkbox, sync
 * the state of any associated conditional reveal with the checkbox state.
 *
 * @deprecated Will be made private in v5.0
 * @param {MouseEvent} event - Click event
 */
Checkboxes.prototype.handleClick = function (event) {
  console.log("LOCALCHECKBOX handleClick")
};


export default Checkboxes
