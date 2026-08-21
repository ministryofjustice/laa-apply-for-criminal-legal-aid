'use strict';

// Accessible conditional reveals
//
// GOV.UK Frontend reveals content nested inside a radio/checkbox by toggling
// the `govuk-*__conditional--hidden` class, which only hides the content
// *visually* (`display: none`). Some browser + screen reader combinations
// (e.g. Chrome + VoiceOver) still expose the nested controls to assistive
// technology, so the reveal's fields — including nested radio groups — get
// announced before the controlling option has been selected.
//
// This module keeps the accessibility state of every GOV.UK conditional reveal
// in sync with its controlling input: when the input is not selected the reveal
// is removed from the accessibility tree (`hidden` + `aria-hidden`) and made
// non-focusable (`inert`); when selected it is restored. It complements, rather
// than replaces, GOV.UK Frontend's own visual toggling and works for any
// `data-aria-controls` reveal (radios and checkboxes).

const CONDITIONAL_CLASS = '__conditional';

function ConditionalReveal($root) {
  this.$root = $root || document;
  this.controls = [];
}

ConditionalReveal.prototype.init = function () {
  const selector = [
    'input[type="radio"][aria-controls]',
    'input[type="radio"][data-aria-controls]',
    'input[type="checkbox"][aria-controls]',
    'input[type="checkbox"][data-aria-controls]'
  ].join(', ');

  this.$root.querySelectorAll(selector).forEach(($input) => {
    const targetId =
      $input.getAttribute('aria-controls') ||
      $input.getAttribute('data-aria-controls');
    if (!targetId) { return }

    const $target = document.getElementById(targetId);
    if (!$target || !$target.className.includes(CONDITIONAL_CLASS)) { return }

    this.controls.push({ $input: $input, $target: $target });
  });

  if (!this.controls.length) { return this }

  this.sync = this.sync.bind(this);
  // GOV.UK Frontend promotes `data-aria-controls` to `aria-controls` and
  // toggles the reveal on `change`, so we listen for the same event and
  // for `pageshow` to cover back/forward (bfcache) navigation.
  this.$root.addEventListener('change', this.sync);
  window.addEventListener('pageshow', this.sync);
  this.sync();

  return this;
};

ConditionalReveal.prototype.sync = function () {
  this.controls.forEach(({ $input, $target }) => {
    const revealed = $input.checked;

    $target.hidden = !revealed;
    $target.inert = !revealed;

    if (revealed) {
      $target.removeAttribute('aria-hidden');
    } else {
      $target.setAttribute('aria-hidden', 'true');
    }
  });
};

export default ConditionalReveal;
