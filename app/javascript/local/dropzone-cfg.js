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
  let uploadTableJS = document.getElementById('upload-table-dropzone')
  uploadTableJS.classList.remove("app-evidence-upload-hidden")
  let uploadTableNonJS = document.getElementById('upload-table-fallback')
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

    let row = createTableRow(file);
    self.$feedbackContainer.querySelector('.govuk-table__body').append(row);
  });

  this.$dropzone.on('success', (file, response) => {
    // Upload table is default hidden from view if there are no uploaded docs,
    // it needs to be made visible if a doc is successfully uploaded
    let uploadTable = document.getElementById('upload-table')
    uploadTable.classList.remove("app-evidence-upload-hidden")

    createDownloadLink(file, response)

    this.$statusTag = document.getElementById(file.upload.uuid).querySelector(".govuk-tag")
    this.$statusTag.classList.remove("govuk-tag--yellow")
    this.$statusTag.classList.add("govuk-tag--green")
    this.$statusTag.innerHTML = "Uploaded"

    amendErrorLink(file, response)
  });

  this.$dropzone.on('error', (file, response) => {
    let errorMsg = generateErrorMessage(file, response)

    this.$tableCell = document.getElementById(file.upload.uuid)
    this.$tableCell.remove();

    let errorSummary = createErrorSummary(errorMsg)
    displayErrorMessage(errorSummary, errorMsg)
  })

  this.$dropzone.on('drop', () => {
    removeErrorMessages()
  })
}

function createTableRow(file) {
  let row = document.createElement("tr")
  let cell = document.createElement("td")
  let span = document.createElement("span")
  let statusTag = createStatusTag("Uploading")
  let errorLink = createDeleteLink()

  row.setAttribute("id", file.upload.uuid)

  row.classList.add("govuk-table__row")
  cell.classList.add("govuk-table__cell")
  span.classList.add("_uploaded_file__filename")

  span.append(file.name)
  cell.append(span)
  cell.append(statusTag)
  row.append(cell)
  row.append(errorLink)
  return row
}

function createStatusTag(text) {
  let tag = document.createElement("strong")
  tag.classList.add("govuk-tag", "govuk-tag--yellow")
  tag.textContent = text
  return tag
}

function createDownloadLink(file, response) {
  const fileEntry = document.getElementById(file.upload.uuid).querySelector("._uploaded_file__filename");

  if (!fileEntry) { return; }

  fileEntry.innerText = "";
  const anchor = document.createElement("a");
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

function createDeleteLink () {
  const deleteEl = document.createElement("td")
  deleteEl.classList.add("govuk-table__cell", "govuk-!-text-align-right")

  const input = document.createElement("input")
  input.setAttribute("type", "hidden")
  input.setAttribute("value", "put")
  input.setAttribute("autocomplete", "off")

  const deleteButton = document.createElement("button")
  deleteButton.classList.add("app-button--link")
  deleteButton.setAttribute("type", "submit")
  deleteButton.setAttribute("name", "document_id")
  deleteButton.innerText = "Delete"

  deleteEl.append(input)
  deleteEl.append(deleteButton)
  return deleteEl
}

function amendErrorLink (file, response) {
  let deleteButton = document.getElementById(file.upload.uuid).querySelector(".app-button--link")
  deleteButton.setAttribute("value", response.id)
}

function removeErrorMessages () {
  // Clear error messages and hide error components from view when user uploads again
  const errorSummary = document.getElementById('error-summary')
  errorSummary.querySelectorAll('li').forEach(listItem => {
    listItem.remove()
  })
  errorSummary.classList.add('app-evidence-upload-hidden')

  document.getElementById('upload-form').classList.remove('govuk-form-group--error')
  document.getElementById('dropzone-error-message').classList.add('app-evidence-upload-hidden')
  document.getElementById('dropzone-error-message').innerHTML = ""
}

function displayErrorMessage(errorSummary, errorMsg) {
  // Display error to top of page
  let pageDiv = document.getElementById('upload-page')
  pageDiv.prepend(errorSummary)

  // Display error above dropzone component
  const uploadFilesElem = document.getElementById('upload-form')
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
