library(shiny.router)
library(shiny)


source("./pages/about.R")
source("./pages/home.R")

router <- make_router(
  route("/", home_page),
  route("about", about_page)
)