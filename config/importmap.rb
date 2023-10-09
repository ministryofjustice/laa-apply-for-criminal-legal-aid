# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "govuk-frontend", to: "https://ga.jspm.io/npm:govuk-frontend@4.7.0/govuk-esm/all.mjs"
pin_all_from "app/javascript/local", under: "local"
pin "accessible-autocomplete", to: "https://ga.jspm.io/npm:accessible-autocomplete@2.0.4/dist/accessible-autocomplete.min.js"
pin "dropzone", to: "https://ga.jspm.io/npm:dropzone@6.0.0-beta.2/dist/dropzone.mjs"
pin "just-extend", to: "https://ga.jspm.io/npm:just-extend@5.1.1/index.esm.js"
