'use strict';

import Dropzone from "dropzone"
import sanitizeFilename from "./sanitize-filename"

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

  // Localised strings injected by the server so JS-rendered content reflects the current locale.
  // Keys mirror the translation keys under the `steps.evidence.upload.edit` scope: to add a
  // string, render it in the `data-dropzone-i18n` JSON blob then reference `this.i18n.<key>`.
  this.i18n = JSON.parse(this.$dropzoneContainer.dataset.dropzoneI18n || '{}')

  // As dropzone and the fallback components share the parent form component, dropzone specific styling is added here
  this.$dropzoneContainer.classList.add("dropzone")

  this.$chooseFilesButton = document.querySelector('button#choose_files_button')

  // Display of choose files button is conditional on whether JS is enabled
  this.$chooseFilesButton.classList.remove("govuk-visually-hidden")

  this.$chooseFilesButton.addEventListener('click', (e) => {
    e.preventDefault() // prevent submitting form by default
  })

  // Display of the uploaded files list is conditional on whether JS is enabled
  let uploadedFilesDropzone = document.getElementById('uploaded-files-dropzone')
  uploadedFilesDropzone.classList.remove("app-evidence-upload-hidden")
  let uploadedFilesFallback = document.getElementById('uploaded-files-fallback')
  uploadedFilesFallback.classList.add("app-evidence-upload-hidden")

  const self = this
  this.$dropzone = new Dropzone(this.$dropzoneContainer, {
    paramName: "document",
    // This component renders its own uploaded-files list, so Dropzone's built-in
    // image preview is unused. Generating it also decodes the image in the browser,
    // and a decode failure makes Dropzone emit an `error` event *during* an upload
    // that is actually succeeding on the server — surfacing a spurious "could not be
    // uploaded" message for images (e.g. JPGs) that are in fact uploaded. Disable it.
    createImageThumbnails: false,
    dictDefaultMessage: this.i18n.drag_and_drop || 'Drag and drop files here or',
    clickable: '#choose_files_button',
    // Sanitise the filename sent to the server so the WAF doesn't reject
    // unsupported characters (e.g. a colon macOS stores in place of a slash).
    renameFile: (file) => sanitizeFilename(file.name)
  })

  this.$dropzoneContainerText = document.querySelector('div.dz-message')
  this.$dropzoneContainerText.appendChild(this.$chooseFilesButton)

  // Outcome of the current batch of uploads, reported once the whole queue completes
  this.batchUploadedFileNames = []
  this.batchErrorCount = 0

  this.$dropzone.on('addedfile', (file) => {
    // Remove any notification banners (e.g. for deleting a file) and error messages from view if present
    const notificationBanner = document.getElementById('notification-banner')
    notificationBanner?.remove()
    hideUploadSuccessBanner()
    removeErrorMessages()

    let row = createUploadedFileRow(file);
    document.querySelector('#uploaded-files-dropzone .app-uploaded-files').append(row);
  });

  this.$dropzone.on('success', (file, response) => {
    // The uploaded files list is default hidden from view if there are no uploaded docs,
    // it needs to be made visible if a doc is successfully uploaded
    let uploadedFilesList = document.getElementById('uploaded-files')
    uploadedFilesList.classList.remove("app-evidence-upload-hidden")

    createDownloadLink(file, response)

    this.$statusTag = document.getElementById(file.upload.uuid).querySelector(".app-uploaded-file__status")
    this.$statusTag.classList.remove("govuk-tag--yellow")
    this.$statusTag.classList.add("govuk-tag--green")
    this.$statusTag.textContent = this.i18n.uploaded || 'Uploaded'

    this.batchUploadedFileNames.push(file.name)

    setDeleteDocumentValue(file, response)
  });

  this.$dropzone.on('error', (file, response) => {
    this.batchErrorCount++

    let errorMsg = generateErrorMessage(file, response)

    this.$row = document.getElementById(file.upload.uuid)
    this.$row.remove();

    let errorSummary = createErrorSummary(errorMsg)
    displayErrorMessage(errorSummary, errorMsg)
  })

  this.$dropzone.on('queuecomplete', () => {
    if (this.batchUploadedFileNames.length > 0) {
      // When any file in the batch failed, focus stays on the error summary
      showUploadSuccessBanner(this.i18n, this.batchUploadedFileNames, this.batchErrorCount === 0)
    }

    this.batchUploadedFileNames = []
    this.batchErrorCount = 0
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

function showUploadSuccessBanner(i18n, fileNames, moveFocus) {
  const banner = document.getElementById('upload-success-banner')

  if (!banner) { return }

  const template = i18n.upload_success || 'You uploaded {{file_name}}'
  const messages = fileNames.map((fileName) => {
    const message = document.createElement('p')
    message.classList.add('govuk-notification-banner__heading')
    message.textContent = template.replace('{{file_name}}', fileName)
    return message
  })

  banner.querySelector('.govuk-notification-banner__content').replaceChildren(...messages)
  banner.hidden = false

  if (moveFocus) { focusWhenDocumentActive(banner) }
}

function hideUploadSuccessBanner() {
  const banner = document.getElementById('upload-success-banner')

  if (banner) { banner.hidden = true }
}

// Screen readers on Windows (NVDA, JAWS) don't reliably announce live region
// updates made while focus is returning from the OS file dialog, as the
// re-announcement of the window and focused button drowns them out. Instead
// focus the visible banner, waiting until the document has focus again so the
// screen reader announces it once it is back in the page.
function focusWhenDocumentActive(element) {
  const focus = () => requestAnimationFrame(() => element.focus())

  if (document.hasFocus()) {
    focus()
  } else {
    window.addEventListener('focus', focus, { once: true })
  }
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
