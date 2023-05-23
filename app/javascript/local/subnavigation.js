'use strict';

function SubNavigation($element) {
  this.$subNavigation = $element
  this.$pageSelector  = '[aria-current="page"]'
}

SubNavigation.prototype.init = function () {
  if (!(this.$subNavigation && window.location.hash)) { return }

  const $currentTab = this.$subNavigation.querySelector(this.$pageSelector)
  if (!$currentTab) { return }

  try {
    const $li = $currentTab.closest('li')

    if ($li) {
      $li.focus()
    }
  } catch(e) {}
}

export default SubNavigation
