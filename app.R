library(shiny)
library(bslib)
library(DBI)
library(duckdb)

source("R/enter_data_modal.R")

con <- dbConnect(duckdb(), dbdir = ":memory:")

dbExecute(con, "
  CREATE TABLE IF NOT EXISTS form_data (
    field1       VARCHAR,
    field2       VARCHAR,
    field3       VARCHAR,
    submitted_at TIMESTAMP
  )
")

table <- tibble::tibble(
  field1 = c("1", "2"),
  field2 = c("1", "2"),
  field3 = c("val1", "val2"),
  submitted_at = Sys.time()
)


dbWriteTable(con, "form_data", table,
          overwrite = TRUE)

ui <- page_fluid(
  theme = bs_theme(version = 5),
  enterDataModalUI("enter_data"),
  tableOutput("data_table")
)

server <- function(input, output, session) {
  # Trigger to refresh table after each submission
  refresh <- reactiveVal(0)

  form_data <- enterDataModalServer("enter_data", db_con = con)

  observeEvent(form_data(), {
    refresh(refresh() + 1)
  })

  output$data_table <- renderTable({
    refresh()
    dbReadTable(con, "form_data")
  })

  onStop(function() {
    dbDisconnect(con, shutdown = TRUE)
  })
}

shinyApp(ui, server)
