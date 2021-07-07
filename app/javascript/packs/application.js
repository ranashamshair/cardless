// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

require("jquery")
window.jQuery = window.$ = require('jquery')
import "src/bootstrap.bundle.min"
import "src/main"
import 'jquery.easing'
import '@popperjs/core'
import intlTelInput from 'src/intlTelInput'
// import 'src/intlTelInput'
// import 'src/utils'

// $("#company_phone").intlTelInput({})

Rails.start()
Turbolinks.start()
ActiveStorage.start()

$(document).on('turbolinks:load', function () {
  var input = document.querySelector("#company_phone");
  if (input) {
    var iti = intlTelInput(input, {
      hiddenInput: "full_phone",
      separateDialCode: true,
      utilsScript: "https://cdn.jsdelivr.net/npm/intl-tel-input@17.0.3/build/js/utils.js",
    });
  }
  
})