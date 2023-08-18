'use strict';

import Dropzone from "dropzone"

function DropzoneCfg(config) {
  this.config = config
}

DropzoneCfg.prototype.init = function () {
  this.$dropzoneContainer = document.querySelector(this.config.dropzoneContainer)
  this.$feedbackContainer = document.querySelector(this.config.feedbackContainer)

  if (!this.$dropzoneContainer || !this.$feedbackContainer) { return }

  const self = this
  this.$dropzone = new Dropzone(this.$dropzoneContainer, {
    paramName: "documents",
    maxFilesize: 20 // MB
  })

  // Basic example of event handling
  this.$dropzone.on("success", file => {
    let div = document.createElement("div")
    div.append(file.name)
    self.$feedbackContainer.querySelector('.govuk-summary-list').append(div);
  });
}

export default DropzoneCfg
