'use strict';

import Dropzone from "dropzone"

const MIN_FILE_SIZE = 3000 // Bytes = 3KB
const MAX_FILE_SIZE = 1000000 // Bytes = 10MB

const ERR_GENERIC = 'could not be uploaded – try again'
const ERR_FILE_SIZE_TOO_BIG = 'must be smaller than 10MB'
const ERR_FILE_SIZE_TOO_SMALL = 'must be bigger than 3KB'
const ERR_CONTENT_TYPE = 'must be a DOC, DOCX, RTF, ODT, JPG, BMP, PNG, TIF, CSV or PDF'
const ALLOWED_CONTENT_TYPES = [
  // dropzone checks both the mimetype and the file extension so this list covers everything
  '.csv', '.doc', '.docx', '.rtf', '.odt', '.jpg', '.jpeg', '.bmp', '.png', '.tif', '.tiff', '.pdf',
  'application/pdf',
  'application/msword',
  'application/vnd.oasis.opendocument.text',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'text/csv',
  'text/rtf',
  'text/plain',
  'application/rtf',
  'image/jpeg',
  'image/png',
  'image/tiff',
  'image/bmp'
]

function DropzoneCfg(config) {
  this.config = config
}

DropzoneCfg.prototype.init = function () {
  this.$dropzoneContainer = document.querySelector(this.config.dropzoneContainer)
  this.$feedbackContainer = document.querySelector(this.config.feedbackContainer)

  if (!this.$dropzoneContainer || !this.$feedbackContainer) { return }

  // As dropzone and the fallback components share the parent form component, dropzone specific styling is added here
  this.$dropzoneContainer.classList.add("dropzone")

  this.$chooseFilesButton = document.querySelector('button#choose_files_button')

  // Display of choose files button is conditional on whether JS is enabled
  this.$chooseFilesButton.classList.remove("govuk-visually-hidden")

  this.$chooseFilesButton.addEventListener('click', (e) => {
    e.preventDefault() // prevent submitting form by default
  })

  // Display of files table (uploaded files only) is conditional on whether JS is enabled
  let uploadTableJS = document.getElementById('uploaded-files-dropzone')
  uploadTableJS.classList.remove("app-evidence-upload-hidden")
  let uploadTableNonJS = document.getElementById('uploaded-files-fallback')
  uploadTableNonJS.classList.add("app-evidence-upload-hidden")

  const self = this
  this.$dropzone = new Dropzone(this.$dropzoneContainer, {
    paramName: "document",
    dictDefaultMessage: 'Drag and drop files here or', // TODO: i18n
    clickable: '#choose_files_button'
  })

  this.$dropzoneContainerText = document.querySelector('div.dz-message')
  this.$dropzoneContainerText.appendChild(this.$chooseFilesButton)

  this.$dropzone.on('addedfile', (file) => {
    // Remove any notification banners (e.g. for deleting a file) and error messages from view if present
    const notificationBanner = document.getElementById('notification-banner')
    notificationBanner?.remove()
    removeErrorMessages()

    let row = createUploadedFileRow(file);
    document.querySelector('#uploaded-files-dropzone .app-uploaded-files').append(row);
  });

  this.$dropzone.on('success', (file, response) => {
    // Upload table is default hidden from view if there are no uploaded docs,
    // it needs to be made visible if a doc is successfully uploaded
    let uploadTable = document.getElementById('uploaded-files')
    uploadTable.classList.remove("app-evidence-upload-hidden")

    createDownloadLink(file, response)

    this.$statusTag = document.getElementById(file.upload.uuid).querySelector(".app-uploaded-file__status")
    this.$statusTag.classList.remove("govuk-tag--yellow")
    this.$statusTag.classList.add("govuk-tag--green")
    this.$statusTag.innerHTML = "Uploaded"

    setDeleteDocumentValue(file, response)
  });

  this.$dropzone.on('error', (file, response) => {
    let errorMsg = generateErrorMessage(file, response)

    this.$row = document.getElementById(file.upload.uuid)
    this.$row.remove();

    let errorSummary = createErrorSummary(errorMsg)
    displayErrorMessage(errorSummary, errorMsg)
  })

  this.$dropzone.on('drop', () => {
    removeErrorMessages()
  })
}

function createUploadedFileRow(file) {
  let row = document.createElement("div")
  let value = document.createElement("dt")
  let span = document.createElement("span")
  let statusTag = createStatusTag("Uploading")
  let actions = createDeleteAction()

  row.setAttribute("id", file.upload.uuid)

  row.classList.add("govuk-summary-list__row", "app-uploaded-file")
  value.classList.add("govuk-summary-list__value")
  span.classList.add("app-uploaded-file__filename")

  span.append(file.name)
  value.append(span)
  value.append(statusTag)
  row.append(value)
  row.append(actions)
  return row
}

function createStatusTag(text) {
  let tag = document.createElement("strong")
  tag.classList.add("govuk-tag", "govuk-tag--yellow", "app-uploaded-file__status")
  tag.textContent = text
  return tag
}

function createDownloadLink(file, response) {
  const fileEntry = document.getElementById(file.upload.uuid).querySelector(".app-uploaded-file__filename");

  if (!fileEntry) { return; }

  fileEntry.innerText = "";
  const anchor = document.createElement("a");
  anchor.classList.add("govuk-link");
  anchor.href = response.url;
  anchor.textContent = file.name;
  fileEntry.append(anchor);
}

function createErrorSummary (msg) {
  const errorSummary = document.getElementById('error-summary')
  const errorSummaryList = document.getElementById('error-summary-list')

  const li = document.createElement('li')
  const a = document.createElement('a')

  li.innerHTML = msg + "<br/><br/>"
  a.innerText += "Try again"
  a.setAttribute('aria-label', msg)
  a.setAttribute('href', '#choose_files_button')

  li.appendChild(a)
  errorSummaryList.appendChild(li)

  errorSummary.classList.remove('app-evidence-upload-hidden')
  errorSummary.scrollIntoView()
  errorSummary.focus()

  return errorSummary
}

function createDeleteAction () {
  const actions = document.createElement("dd")
  actions.classList.add("govuk-summary-list__actions")

  const deleteButton = document.createElement("button")
  deleteButton.classList.add("app-button--link", "app-uploaded-file__delete")
  deleteButton.setAttribute("type", "submit")
  deleteButton.setAttribute("name", "document_id")
  deleteButton.innerText = "Delete"

  actions.append(deleteButton)
  return actions
}

function setDeleteDocumentValue (file, response) {
  let deleteButton = document.getElementById(file.upload.uuid).querySelector(".app-uploaded-file__delete")
  deleteButton.setAttribute("value", response.id)
}

function removeErrorMessages () {
  // Clear error messages and hide error components from view when user uploads again
  const errorSummary = document.getElementById('error-summary')
  errorSummary.querySelectorAll('li').forEach(listItem => {
    listItem.remove()
  })
  errorSummary.classList.add('app-evidence-upload-hidden')

  document.getElementById('upload-form-group').classList.remove('govuk-form-group--error')
  document.getElementById('dropzone-error-message').classList.add('app-evidence-upload-hidden')
  document.getElementById('dropzone-error-message').innerHTML = ""
}

function displayErrorMessage(errorSummary, errorMsg) {
  // Display error to top of page
  let pageDiv = document.getElementById('upload-page')
  pageDiv.prepend(errorSummary)

  // Display error above dropzone component
  const uploadFilesElem = document.getElementById('upload-form-group')
  uploadFilesElem.classList.add('govuk-form-group--error')
  const errorMessage = document.getElementById('dropzone-error-message')

  errorMessage.innerHTML += errorMsg + "<br />"
  errorMessage.classList.remove('app-evidence-upload-hidden')
}

function generateErrorMessage(file, response) {
  let errorMsg = file.name + ' '

  if (!ALLOWED_CONTENT_TYPES.includes(file.type)) {
    errorMsg += ERR_CONTENT_TYPE
  } else if (file.size >= MAX_FILE_SIZE) {
    errorMsg += ERR_FILE_SIZE_TOO_BIG
  } else if (file.size <= MIN_FILE_SIZE) {
    errorMsg += ERR_FILE_SIZE_TOO_SMALL
  } else if (response.error_message !== '') {
    errorMsg = response.error_message
  } else {
    errorMsg += ERR_GENERIC
  }
  return errorMsg
}
export default DropzoneCfg
