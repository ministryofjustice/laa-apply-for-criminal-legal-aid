'use strict';

function PrintAction($element) {
  this.$element = $element
}

PrintAction.prototype.init = function() {
  const self = this
  this.$element.addEventListener('click', self.print.bind(self))
}

PrintAction.prototype.print = function(e) {
  window.print()
  e.preventDefault()
}

export default PrintAction
