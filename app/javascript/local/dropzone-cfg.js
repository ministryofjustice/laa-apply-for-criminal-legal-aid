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
    maxFilesize: 20, // MB
    dictDefaultMessage : 'Drag and drop files here or',
    clickable: '#choose_files_button'
  })

  this.$dropzoneContainerText = document.querySelector('div.dz-message')
  this.$chooseFilesButton = document.querySelector('button#choose_files_button')
  this.$dropzoneContainerText.appendChild(this.$chooseFilesButton)
}

export default DropzoneCfg
