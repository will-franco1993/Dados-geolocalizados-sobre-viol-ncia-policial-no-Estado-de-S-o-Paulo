library(shiny)
library(plotly)
library(DT)


predictive_page <- div(
  fluidRow(titlePanel("Tabela de Dados"), align = "center"),
  fluidRow(selectInput('tipo_table', "Selecione uma Tabela",
                       list("Tabela Geral"='geral', "Tabela de Vitimas por Cor"='vit_cor', "Tabelas de Vitima por Genero e Raça"='vit_gen_ra',
                            "Tabela da Idade e Cor"='ida_cor')
  ), align = "center"),
  
  fluidRow(column(
    10,
    offset = 1, DT::dataTableOutput("data_table")
  ))
)
