library(shiny)


css_content <- "
.checks {
padding-left: 20px;
color: black;
border: 25px;
padding-top: 10px;
padding-bottom: 10px;
}

body{
background-color: white;
heigth: 100vh
}

hr.solid {
  border-top: 3px solid #bbb;
}

.sta-content{
background-color: #454545;
height: 120px;
border-radius: 25px;
padding-top: 10px;
color:white;
}

.number{
color: white;
font-size: 18px;
font-weigth: 700;
padding-top: 15px;
display: flex;
flex-direction: row;
width: 100%;
justify-content: center;
  align-items: center;
}
"

statistics_page <- div(
  class = "statistica-page",
  tags$head(tags$style(HTML(css_content))),

  # titlePanel(
  #  div(h2("Estatisticas", style='color:black', align='center'), tags$br())),

  h4(
    "Serie Temporal de Vitimas da Violencia Policial",
    style = "color:black",
    align = "center"
  ),
  fluidRow(column(
    10, plotlyOutput("timeseries_statistics"),
    offset = 1
  )),
  tags$br(),
  tags$hr(class = "solid"),
  tags$br(),
  h4(
    "Medidas Resumo da Serie Historicas de Vitimas",
    style = "color:black",
    align = "center"
  ),
  fluidRow(
    align = "center",
    column(
      2,
      offset = 2,
      align = "center",
      div(
        class = "sta-content",
        "Média de Vitimas por Ano",
        tags$br(),
        div(class = "number", textOutput("vit_ano"), " ± ", textOutput("std_ano"))
      )
    ),
    column(
      2,
      offset = 1,
      align = "center",
      div(
        class = "sta-content",
        "Média de Vitimas por Mes",
        tags$br(),
        div(class = "number", textOutput("vit_mes"), " ± ", textOutput("std_mes"))
      )
    ),
    column(
      2,
      offset = 1,
      align = "center",
      div(
        class = "sta-content",
        "Média de Vitimas por Dia",
        tags$br(),
        div(class = "number", textOutput("vit_dia"), " ± ", textOutput("std_dia"))
      )
    ),
  ),
  tags$br(),
  tags$hr(class = "solid"),
  tags$br(),
  h4(
    "Relação entre Cor/Raça das Vitimas de Violencia Policial a Cada Ano",
    style = "color:black",
    align = "center"
  ),
  fluidRow(column(10, plotOutput("rel_cor_vio"),
    offset =
      1
  )),
  tags$br(),
  tags$hr(class = "solid"),
  tags$br(),
  h4(
    "Mortes causadas por intervenção policial em SP por raça e gênero",
    style = "color:black",
    align = "center"
  ),
  fluidRow(column(
    10, plotlyOutput("mortes_raca_cor"),
    offset = 1
  )),
  tags$br(),
  tags$hr(class = "solid"),
  tags$br(),
  h4(
    "Distribuição do Horario de Ocorrencia da Violencia Policial",
    style = "color:black",
    align = "center"
  ),
  fluidRow(column(
    10, plotlyOutput("dist_hour_violence"),
    offset = 1
  )),
  tags$br(),
  tags$hr(class = "solid"),
  tags$br(),
  h4(
    "Mortes causadas por intervenção policial em SP entre 2013 e 2021",
    style = "color:black",
    align = "center"
  ),
  fluidRow(column(
    10, plotlyOutput("mortes_anos_bar"),
    offset = 1
  )),
  tags$br(),
  tags$hr(class = "solid"),
  tags$br(),
  h4(
    "Mortes causadas por intervenção policial em SP entre 2013 e 2021",
    style = "color:black",
    align = "center"
  ),
  fluidRow(column(
    10, plotlyOutput("mortes_anos_pie"),
    offset = 1
  )),
  tags$br(),
  tags$hr(class = "solid"),
  tags$br(),
  h4(
    "Boxplot da Idade das Vitimas por Cor/Raça",
    style = "color:black",
    align = "center"
  ),
  fluidRow(column(10, plotlyOutput("boxplot_idade_cor"),
                  offset =
                    1
  )),
  tags$br(),
  tags$hr(class = "solid"),
  tags$br(),
  h4(
    "Coorporações Policiais Mais Violentas",
    style = "color:black",
    align = "center"
  ),
  fluidRow(column(
    10, plotlyOutput("bar_copr_vio"),
    offset = 1
  )),
  tags$br(),
  tags$hr(class = "solid"),
  tags$br(),
  h4(
    "Boxplot da Idade das Vitimas ao Longo dos Anos",
    style = "color:black",
    align = "center"
  ),
  fluidRow(column(10, plotOutput("boxplot_idade"),
    offset =
      1
  )),
)
