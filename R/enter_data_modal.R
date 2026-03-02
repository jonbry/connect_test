enterDataModalUI <- function(id) {
  ns <- NS(id)
  actionButton(ns("enter_data_btn"), "Enter Data", class = "btn-primary mt-3")
}

enterDataModalServer <- function(id, db_con) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observeEvent(input$enter_data_btn, {
      showModal(modalDialog(
        title = "Enter Data",
        textInput(ns("field1"), "Field 1"),
        textInput(ns("field2"), "Field 2"),
        selectInput(
          ns("field3"), "Field 3",
          choices = c("val 1", "val 2", "val 3")
        ),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("submit_btn"), "Submit", class = "btn-primary")
        )
      ))
    })

    observeEvent(input$submit_btn, {
      new_row <- data.frame(
        field1       = input$field1,
        field2       = input$field2,
        field3       = input$field3,
        submitted_at = Sys.time()
      )
      DBI::dbAppendTable(db_con, "form_data", new_row)
      removeModal()
    })

    # Return submitted values as a reactive
    reactive({
      req(input$submit_btn)
      list(
        field1 = input$field1,
        field2 = input$field2,
        field3 = input$field3
      )
    })
  })
}
