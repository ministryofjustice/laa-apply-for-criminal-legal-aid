'use strict';

import Dropzone from "dropzone"

function DropzoneCfg(config) {
  this.config = config
}

DropzoneCfg.prototype.init = function () {
  this.$dropzoneContainer = document.querySelector(this.config.dropzoneContainer)
  this.$feedbackContainer = document.querySelector(this.config.feedbackContainer)

  if (!this.$dropzoneContainer || !this.$feedbackContainer) { return }

  // Display of choose files button is conditional on whether JS is enabled
  document.getElementById('choose_files_button').classList.remove("govuk-visually-hidden")

  const self = this
  this.$dropzone = new Dropzone(this.$dropzoneContainer, {
    paramName: "document",
    dictDefaultMessage: 'Drag and drop files here or', // TODO: i18n
    clickable: '#choose_files_button'
  })

  this.$dropzoneContainerText = document.querySelector('div.dz-message')
  this.$chooseFilesButton = document.querySelector('button#choose_files_button')
  this.$dropzoneContainerText.appendChild(this.$chooseFilesButton)
}

export default DropzoneCfg
