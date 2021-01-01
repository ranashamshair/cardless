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
import "src/bootstrap.min"
import "src/adminlte"
import "src/demo"
// import "src/dashboard3"
import 'datatables.net-bs4'
// import "src/jquery.dataTables"
// import "src/dataTables.bootstrap4"
// import "src/dataTables.responsive"
// import "src/responsive.bootstrap4"
import "src/admin_custom"
// import DataTable from 'datatables'
// window.DataTable = DataTable


Rails.start()
Turbolinks.start()
ActiveStorage.start()

