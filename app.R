library(shiny)
library(bslib)
library(DBI)
library(duckdb)

source("R/enter_data_modal.R")

# Connect to DuckDB (creates the file if it doesn't exist)
con <- dbConnect(duckdb(), dbdir = "data/app_data.duckdb")

dbExecute(con, "
  CREATE TABLE IF NOT EXISTS form_data (
    field1       VARCHAR,
    field2       VARCHAR,
    field3       VARCHAR,
    submitted_at TIMESTAMP
  )
")

ui <- page_fluid(
  theme = bs_theme(version = 5),
  enterDataModalUI("enter_data")
)

server <- function(input, output, session) {
  form_data <- enterDataModalServer("enter_data", db_con = con)

  # Close DB connection cleanly when session ends
  onStop(function() {
    dbDisconnect(con, shutdown = TRUE)
  })
}

shinyApp(ui, server)
