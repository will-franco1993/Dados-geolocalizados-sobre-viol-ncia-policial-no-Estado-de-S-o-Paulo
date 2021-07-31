library(shiny)
library(bslib)
library(rgdal)
library(leaflet)


new_media_content <- "

body{
background-color: #454c57;
}

@media (max-width: 955px) {
    .navbar-header .navbar-brand {float: left; text-align: center; width: 100%}
    .navbar-header { width:100% }
.navbar-brand { width: 100%; text-align: center }

}

#statemap {
border-radius: 25px;
}

.leaflet-overlay-pane{
border-radius: 25px;

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
flex-direction: row;
display: flex;
background-color: #454c57;
}

.map-div{
  width: 55%;
  margin-left: 30px;
  height: calc(100vh - 69px- 20px);
  margin-bottom: 20px;
   border-radius: 25px;
}

div.outer {
  position: fixed;
  top: 50px;
  left: 0;
  right: 0;
  bottom: 0;
  overflow: hidden;
  padding: 0;
}



@media (max-width: 768px) {
div.outer {
  position: fixed;
  top: 245px;
  left: 0;
  right: 0;
  bottom: 0;
  overflow: hidden;
  padding: 0;
}


.content-home{
flex-direction: column;
display: flex;
}
}

@media (min-width: 769px) and (max-width: 956px) {
div.outer {
  position: fixed;
  top: 100px;
  left: 0;
  right: 0;
  bottom: 0;
  overflow: hidden;
  padding: 0;
}
.side-content{
height: calc(100vh - 121px - 20px);
}
}

.leaflet{
border-radius: 25px;
}

.filter-component{
width: 100%;
padding-left: 15px;
padding-right: 15px;
}

hr.solid {
  border-top: 3px solid #bbb;
}




#controls:hover {
  opacity: 0.95;
  transition-delay: 0;
}


#controls {
  background-color: white;
  padding: 0 20px 20px 20px;

  opacity: 0.65;
  transition: opacity 300ms 200ms;
}

"


home_content <- div( # Head with styles
  tags$head(tags$style(HTML(new_media_content))),
  div(
    class = "outer",
    leafletOutput("statemap", height = "100%", ),
    absolutePanel(
      id = "controls",
      class = "panel panel-default",
      fixed = TRUE,
      draggable = T,
      top = 290,
      left = "auto",
      right = 20,
      bottom = "auto",
      width = 340,
      height = "auto",
      h4("Mapa Interativo"),
      hr(class = "solid"),
      radioButtons(
        "mapgroupment",
        "Granularidade da Visualização",
        c(
          "Dados por Municipio" = "mun",
          "Pontos da Ocorrencia" = "point"
        )
      ),
      sliderInput(
        "mapyear",
        "Ano",
        animate = animationOptions(interval = 2000, loop = F),
        min = 2013,
        max = 2021,
        value = c(2019, 2021),
        sep = "",
        dragRange = T,
        ticks = F,
        width = "100%"
      ),
      radioButtons(
        "corgroupment",
        "Cor e Raça",
        c(
          "Todos" = "all",
          "Pretos e Pardos" = "pp",
          "Brancos e Amarelos" = "ba",
          "Não Informado" = "nf"
        )
      ),
      actionButton("filterbtn", "Filtrar")
    )
  ),
)
