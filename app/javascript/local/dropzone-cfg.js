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

  this.$dropzone.on('addedfile', (file, response) => {
    let row = createTableRow(file);
    self.$feedbackContainer.querySelector('.govuk-table__body').append(row);
  });

  this.$dropzone.on('success', (file, response) => {
    this.$statusTag = document.getElementById(file.upload.uuid).querySelector(".govuk-tag")
    this.$statusTag.classList.remove("govuk-tag--yellow")
    this.$statusTag.classList.add("govuk-tag--green")
    this.$statusTag.innerHTML = "Uploaded"
  });

  this.$dropzone.on('error', (file, response) => {
    let error = createErrorMessage(response.error_message)
    this.$tableCell = document.getElementById(file.upload.uuid)
    this.$tableCell.append(error)
    this.$statusTag = this.$tableCell.querySelector(".govuk-tag")
    this.$tableCell.removeChild(this.$statusTag)
  })
}
function createTableRow(file) {
  let row = document.createElement("tr")
  let cell = document.createElement("td")
  let statusTag = createStatusTag("Uploading")

  cell.setAttribute("id", file.upload.uuid)

  row.classList.add("govuk-table__row")
  cell.classList.add("govuk-table__cell")

  cell.append(file.name)
  cell.append(statusTag)
  row.append(cell)
  return row
}

function createStatusTag(text) {
  let tag = document.createElement("strong")
  tag.classList.add("govuk-tag", "govuk-tag--yellow")
  tag.textContent = text
  return tag
}

function createErrorMessage (msg) {
  const errorEl = document.createElement("p")
  errorEl.classList.add("govuk-error-message")

  // to assist screen reader users
  const screenReaderError = document.createElement("span")
  screenReaderError.classList.add("govuk-visually-hidden")
  screenReaderError.textContent = "Error:"

  errorEl.textContent = msg
  errorEl.prepend(screenReaderError)
  return errorEl
}
export default DropzoneCfg
