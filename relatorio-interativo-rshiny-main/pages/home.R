library(shiny)
library(bslib)

source("./pages/about.R")
source("./pages/home_content.R")
source("./pages/predictive.R")
source("./pages/statistics.R")

new_media <- "

@media (max-width: 955px) {
    .navbar-header .navbar-brand {float: left; text-align: center; width: 100%}
    .navbar-header { width:100% }
.navbar-brand { width: 100%; text-align: center }

}

.container-fluid {
    padding-right: 0px;
    padding-left: 0px;
    margin-right: auto;
    margin-left: auto;
}

.nav
{
    padding-left: 15px;

}

.navbar-inverse .navbar-brand{
  color: white
}

.navbar-brand:hover {
    color: white;
}


@media (min-width: 956px) {
    .navbar {width:100%}
    .navbar .navbar-nav {float: right}
    .navbar .navbar-header {float: left}
    .navbar-brand { float: left; padding-left: 30px;  }
}

.content-home{
width: 100%
}

.map-div{
  width: 60%;
  margin-left: 30px
}

"


home_page <- fluidPage(
  tags$head(tags$style(HTML(new_media))),
  
  
  navbarPage(
    inverse = T,
    title = "Violencia Decorrente de\n Intervenção Policial - SP",
    tabPanel(title = "Mapa Interativo", home_content),
    tabPanel(title = "Estatisticas", statistics_page),
    tabPanel(title = "Tabela", predictive_page),
    tabPanel(title = "Sobre", about_page),
    tags$style(HTML(new_media))
  ),
  
)
