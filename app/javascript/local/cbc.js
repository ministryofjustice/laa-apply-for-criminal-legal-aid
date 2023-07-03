'use strict';

function Cbc($module) {
  this.$cookieBanner = $module
  this.$hideButtonSelector = '.app--js-cookie-banner-hide'
}

Cbc.prototype.init = function () {
  const self = this,
        $hideButton = this.$cookieBanner.querySelector(this.$hideButtonSelector)

  if ($hideButton) {
    $hideButton.addEventListener('click', self.hideBanner.bind(self))
  }
}

Cbc.prototype.hideBanner = function (e) {
  this.$cookieBanner.setAttribute('hidden', true)
  e.preventDefault()
}

export default Cbc
