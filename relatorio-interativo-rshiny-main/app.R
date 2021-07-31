library(shiny)
library(leaflet)
library(rgdal)
library(plotly)
library(DT)


source("./components/route.R")

ui <- bootstrapPage(div(router$ui))

server <- function(input, output, session) {
  # Server routes
  router$server(input, output, session)
  print("./state_dataset/SP_Mun97_region")
  stateShape <- readOGR("./state_dataset/", "SP_Mun97_region")

  MDIP_df <- read.csv("./datasets/formated_MPID.csv", sep = "\t")

  df <- transform(MDIP_df, LATITUDE = as.numeric(LATITUDE))
  df <- transform(df, LONGITUDE = as.numeric(LONGITUDE))
  df <- transform(df, ANO_BO = as.numeric(ANO_BO))

  dfcopy <- data.frame(df[!is.na(df$CIDADE_ELABORACAO), ])
  initied <- F

  f <- function(x) {
    data <- x[7]
    genero <- x[22]
    idade <- x[23]
    cor <- x[24]
    profissao <- x[26]
    return(
      sprintf(
        "<strong>Genero: %s</strong><br/>Idade: %s</sup><br/>Cor: %s</sup><br/>Profissão: %s</sup><br/>Data do Ocorrido: %s</sup>",
        as.character(genero),
        as.character(idade),
        as.character(cor),
        as.character(profissao),
        as.character(data)
      )
    )
  }

  Mode <- function(x) {
    ux <- unique(x)
    ux[which.max(tabulate(match(x, ux)))]
  }


  output$data_table <- DT::renderDataTable({
    if (input$tipo_table == "geral"){
      data <- subset(df, select = -X)
      data <- subset(data, select = -Unnamed..0.1.1.1)
      data <- subset(data, select = -Unnamed..0.1.1.1.1)

      
      
      datatable(
        data,
        rownames = FALSE,
        extensions = "Buttons",
        options = list(
          dom = "Bfrtip",
          buttons = I("colvis"),
          scrollX = TRUE
        )
      )
    }else if(input$tipo_table == "vit_cor") {
      
      dados_mortes_raça <- data.frame( Raça = c('Parda', 'Branca', 'Preta',
                                                'NÃO INFORMADO', 'Amarela' ),
                                       Mortes = c(3640, 2312, 648,293, 3),
                                       
                                       stringsAsFactors = FALSE
                                       
      )
      datatable(
        dados_mortes_raça,
        rownames = FALSE,
        extensions = "Buttons",
        options = list(
          dom = "Bfrtip",
          scrollX = TRUE
        )
      )
      
    }else if(input$tipo_table == "vit_gen_ra") {
      
      dados_genero_raca <- data.frame(COR=df$COR_FOMATADO,SEXO=df$SEXO_FOMATADO)
      
      datatable(
        dados_genero_raca,
        rownames = FALSE,
        extensions = "Buttons",
        options = list(
          dom = "Bfrtip",
          scrollX = TRUE
        )
      )
      
    }else if(input$tipo_table == "ida_cor") {
      
      dados_idade_raça <- data.frame(IDADE=df$IDADE_PESSOA, COR_FOMATADO=df$COR)
      
      dados_idade_raça <- dados_idade_raça %>% filter(IDADE != 'NÃO INFORMADO'
                                                      & IDADE != 'REGISTRADO NA PF')
      
      datatable(
        dados_idade_raça,
        rownames = FALSE,
        extensions = "Buttons",
        options = list(
          dom = "Bfrtip",
          scrollX = TRUE
        )
      )
      
    }
    
  })





  output$timeseries_statistics <- renderPlotly({
    fig <- plot_ly(mode = "line")


    filtered_timeseries <-
      df %>% filter(COR == "Branca" | COR == "Amarela")
    aggregated_freq <- aggregate(
      filtered_timeseries[, 31],
      list(filtered_timeseries$ANO_BO),
      length
    )
    fig <-
      fig %>% add_trace(
        x = aggregated_freq$Group.1,
        y = aggregated_freq$x,
        name = "Brancos e Amarelos"
      )


    filtered_timeseries <-
      df %>% filter(COR == "Preta" | COR == "Parda")
    aggregated_freq <- aggregate(
      filtered_timeseries[, 31],
      list(filtered_timeseries$ANO_BO),
      length
    )
    fig <-
      fig %>% add_trace(
        x = aggregated_freq$Group.1,
        y = aggregated_freq$x,
        name = "Pretos e Pardos"
      )


    filtered_timeseries <-
      df %>% filter(COR == "NÃO INFORMADO" |
        COR == "Ignorada" | COR == "Outros")
    aggregated_freq <- aggregate(
      filtered_timeseries[, 31],
      list(filtered_timeseries$ANO_BO),
      length
    )
    fig <-
      fig %>% add_trace(
        x = aggregated_freq$Group.1,
        y = aggregated_freq$x,
        name = "Não Informaados"
      )



    fig <- fig %>% layout(
      xaxis = list(title = "Anos"),
      yaxis = list(title = "Vitimas")
    )
  })
  
  output$boxplot_idade_cor <- renderPlotly({
    
    dados_idade_raça <- data.frame(IDADE_PESSOA=df$IDADE_PESSOA, COR_FOMATADO=df$COR_FOMATADO)
    
    dados_idade_raça <- dados_idade_raça %>% filter(IDADE_PESSOA != 'NÃO INFORMADO'
                                                    & IDADE_PESSOA != 'REGISTRADO NA PF')
    

    fig6 <- plot_ly(dados_idade_raça, y= ~IDADE_PESSOA, color = ~COR_FOMATADO,
                    type = 'box') %>% layout(yaxis=list(title="Idade"), xaxis=list(title="Cor"))
  })

  output$rel_cor_vio <- renderPlot({
    fig <- plot_ly(mode = "bar")

    label <- c()
    label2 <- c()
    label3 <- c()

    filtered_timeseries <-
      df %>% filter(COR == "Branca" | COR == "Amarela")
    aggregated_freq_1 <- aggregate(
      filtered_timeseries[, 31],
      list(filtered_timeseries$ANO_BO),
      length
    )

    for (i in aggregated_freq_1$Group.1) {
      label <- c(label, "Brancos e Amarelos")
    }

    data1 <-
      data.frame(
        ano = aggregated_freq_1$Group.1,
        freq = aggregated_freq_1$x,
        cor = label
      )


    filtered_timeseries <-
      df %>% filter(COR == "Preta" | COR == "Parda")
    aggregated_freq_2 <- aggregate(
      filtered_timeseries[, 31],
      list(filtered_timeseries$ANO_BO),
      length
    )

    for (i in aggregated_freq_2$Group.1) {
      label2 <- c(label2, "Pretos e Pardos")
    }

    data2 <-
      data.frame(
        ano = aggregated_freq_2$Group.1,
        freq = aggregated_freq_2$x,
        cor = label2
      )

    filtered_timeseries <-
      df %>% filter(COR == "NÃO INFORMADO" |
        COR == "Ignorada" | COR == "Outros")
    aggregated_freq_3 <- aggregate(
      filtered_timeseries[, 31],
      list(filtered_timeseries$ANO_BO),
      length
    )

    for (i in aggregated_freq_3$Group.1) {
      label3 <- c(label3, "Não Informado")
    }

    data3 <-
      data.frame(
        ano = aggregated_freq_3$Group.1,
        freq = aggregated_freq_3$x,
        cor = label3
      )

    merged <- rbind(data1, data2)
    merged <- rbind(merged, data3)

    ggplot(merged, aes(fill = cor, y = freq, x = ano)) +
      geom_bar(position = "stack", stat = "identity") +
      ylab("Vitimas") +
      xlab("Ano") +
      labs(fill = "Cor/Raça")
  })

  output$mortes_raca_cor <- renderPlotly({
    dados_genero_raca <- data.frame(df$COR_FOMATADO, df$SEXO_FOMATADO)
    tab <- table(dados_genero_raca)
    tab <- as.data.frame(tab)

    fig3 <- tab %>%
      plot_ly(
        x = ~df.COR_FOMATADO,
        y = ~Freq,
        color = ~df.SEXO_FOMATADO,
        type = "bar"
      ) %>%
      layout(
        xaxis = list(title = "Cor/Raça das vítimas"),
        yaxis = list(title = "Mortes")
      )
  })

  output$mortes_anos_bar <- renderPlotly({
    dados_mortes_raça <-
      data.frame(
        Raça = c(
          "Parda", "Branca", "Preta",
          "NÃO INFORMADO", "Amarela"
        ),
        Mortes = c(3640, 2312, 648, 293, 3),
        stringsAsFactors = FALSE
      )
    fig2 <- dados_mortes_raça %>%
      plot_ly(
        x = ~Raça,
        y = ~Mortes,
        type = "bar"
      )
    fig2 <- fig2 %>% layout()

    fig2
  })

  output$mortes_anos_pie <- renderPlotly({
    dados_mortes_raça <-
      data.frame(
        Raça = c(
          "Parda", "Branca", "Preta",
          "NÃO INFORMADO", "Amarela"
        ),
        Mortes = c(3640, 2312, 648, 293, 3),
        stringsAsFactors = FALSE
      )

    fig1 <-
      plot_ly(
        dados_mortes_raça,
        labels = ~Raça,
        values = ~Mortes,
        type = "pie"
      )
    fig1 <- fig1 %>% layout()
    fig1
  })


  output$bar_copr_vio <- renderPlotly({
    aggregated_freq_3 <- aggregate(df[, 31], list(df$COORPORAÇÃO), length)

    data_ <-
      data.frame(Coorporação = aggregated_freq_3$Group.1, Vitimas = aggregated_freq_3$x)

    ggplot(data_, aes(y = Vitimas, x = Coorporação)) +
      geom_bar(
        position = "dodge",
        stat = "identity",
        width = 0.5
      ) +
      ylab("Vitimas da Violencia Policial") +
      xlab("Cooporação Policial")
  })


  output$dist_hour_violence <- renderPlotly({
    filter_nan <- df %>% filter(HORA_FATO != "NÃO INFORMADO")
    fig <- plot_ly(
      filter_nan,
      x =  ~ as.numeric(HORA_FATO_HOUR_ONLY, rm.na = T),
      type = "histogram",
      alpha = 0.6
    ) %>% layout(xaxis = list(title = ""))
  })

  output$vit_ano <- renderText({
    aggregated_freq <- aggregate(df[, 31], list(df$ANO_BO), length)
    print(as.character(round(mean(
      aggregated_freq$x
    ), digits = 1)))
  })
  output$vit_mes <- renderText({
    aggregated_freq <- aggregate(df[, 31], list(df$ANO_BO), length)
    print(as.character(round(mean(
      aggregated_freq$x
    ) / 12, digits = 1)))
  })
  output$vit_dia <- renderText({
    aggregated_freq <- aggregate(df[, 31], list(df$ANO_BO), length)
    print(as.character(round(
      mean(aggregated_freq$x) / 365,
      digits = 1
    )))
  })

  output$std_ano <- renderText({
    aggregated_freq <- aggregate(df[, 31], list(df$ANO_BO), length)
    print(as.character(round(
      var(aggregated_freq$x)**(1 / 2),
      digits = 1
    )))
  })
  output$std_mes <- renderText({
    aggregated_freq <- aggregate(df[, 31], list(df$ANO_BO), length)
    print(as.character(round((
      var(aggregated_freq$x)**(1 / 2)
    ) / 12, digits = 1)))
  })
  output$std_dia <- renderText({
    aggregated_freq <- aggregate(df[, 31], list(df$ANO_BO), length)
    print(as.character(round((
      var(aggregated_freq$x)**(1 / 2)
    ) / 365, digits = 1)))
  })


  output$boxplot_idade <- renderPlot({
    filter_nan <- df %>% filter(IDADE_PESSOA != "NÃO INFORMADO")
    filter_nan$IDADE_PESSOA <- as.factor(filter_nan$IDADE_PESSOA)

    boxplot(
      IDADE_PESSOA ~ ANO_BO,
      data = filter_nan,
      xlab = "Anos",
      ylab = "Idade da Vitima"
    )
  })


  output$statemap <- renderLeaflet({
    filtered <- df[df["ANO_BO"] >= 2019 & df["ANO_BO"] <= 2021, ]

    aggregated_freq <- aggregate(filtered[, 33], list(filtered$MUNICIPIO_CIRC), length)
    only_number <- transform(filtered[grep("[[:digit:]]", filtered$IDADE_PESSOA), ], IDADE_PESSOA = as.numeric(IDADE_PESSOA))
    aggregated_freq_idade <- aggregate(only_number[, 25], list(only_number$MUNICIPIO_CIRC), mean, )
    aggregated_freq_cor <- aggregate(filtered[, 26], list(filtered$MUNICIPIO_CIRC), Mode)
    labels <- c()
    density <- c()
    for (name in stateShape$SEM_ACENTO) {
      dens <- 0
      idade <- 0
      cor <- ""
      percentage <- 0
      if (!is.na(aggregated_freq[aggregated_freq["Group.1"] == toupper(gsub("SAO ", "S.", name))][2])) {
        dens <- as.numeric(aggregated_freq[aggregated_freq["Group.1"] == toupper(gsub("SAO ", "S.", name))][2])
      }
      if (!is.na(aggregated_freq_idade[aggregated_freq_idade["Group.1"] == toupper(gsub("SAO ", "S.", name))][2])) {
        idade <- as.numeric(aggregated_freq_idade[aggregated_freq_idade["Group.1"] == toupper(gsub("SAO ", "S.", name))][2])
      }
      if (!is.na(aggregated_freq_cor[aggregated_freq_cor["Group.1"] == toupper(gsub("SAO ", "S.", name))][2])) {
        cor <- as.character(aggregated_freq_cor[aggregated_freq_cor["Group.1"] == toupper(gsub("SAO ", "S.", name))][2])
        aux <- filtered["COR"]
        percentage <- length(aux[aux["COR"] == as.character(cor)]) / nrow(filtered)
      }

      labels <- c(labels, htmltools::HTML(paste(
        sprintf(
          "<strong>%s</strong><br/>Vitimas: %g</sup><br/>Idade Média das Vitimas: %g</sup><br/>Raça/Cor com mais Vitimas: <strong>%s</strong> (%g",
          name,
          dens,
          round(idade, digits = 0),
          cor,
          round(as.numeric(percentage) * 100, digits = 2)
        ),
        "%)"
      )))
      density <- c(density, dens)
    }


    stateShape$labels <- labels
    stateShape$density <- density
    bins <- c(0, 2, 4, 8, 16, 32, 64, 128, Inf)
    pal <-
      colorBin("YlOrRd", domain = stateShape$density, bins = bins)

    leaflet(stateShape, height = "100%") %>%
      addTiles() %>%
      addPolygons(
        color = "#444444",
        weight = 1,
        smoothFactor = 0.5,
        opacity = 1.0,
        fillOpacity = 0.1
      ) %>%
      clearGroup("densidade") %>%
      clearMarkers() %>%
      addPolygons(
        color = "#444444",
        data = stateShape,
        weight = 0.5,
        smoothFactor = 0.5,
        opacity = 1.0,
        fillOpacity = 0.8,
        fillColor = ~ pal(density),
        popup = lapply(labels, htmltools::HTML),
        group = "densidade"
      )
  })





  deal_with_agrouped_clorophet <- function(filtered) {
    aggregated_freq <- aggregate(filtered[, 33], list(filtered$MUNICIPIO_CIRC), length)
    only_number <- transform(filtered[grep("[[:digit:]]", filtered$IDADE_PESSOA), ], IDADE_PESSOA = as.numeric(IDADE_PESSOA))
    aggregated_freq_idade <- aggregate(only_number[, 25], list(only_number$MUNICIPIO_CIRC), mean, )
    aggregated_freq_cor <- aggregate(filtered[, 26], list(filtered$MUNICIPIO_CIRC), Mode)
    labels <- c()
    density <- c()
    for (name in stateShape$SEM_ACENTO) {
      dens <- 0
      idade <- 0
      cor <- ""
      percentage <- 0
      if (!is.na(aggregated_freq[aggregated_freq["Group.1"] == toupper(gsub("SAO ", "S.", name))][2])) {
        dens <- as.numeric(aggregated_freq[aggregated_freq["Group.1"] == toupper(gsub("SAO ", "S.", name))][2])
      }
      if (!is.na(aggregated_freq_idade[aggregated_freq_idade["Group.1"] == toupper(gsub("SAO ", "S.", name))][2])) {
        idade <- as.numeric(aggregated_freq_idade[aggregated_freq_idade["Group.1"] == toupper(gsub("SAO ", "S.", name))][2])
      }
      if (!is.na(aggregated_freq_cor[aggregated_freq_cor["Group.1"] == toupper(gsub("SAO ", "S.", name))][2])) {
        cor <- as.character(aggregated_freq_cor[aggregated_freq_cor["Group.1"] == toupper(gsub("SAO ", "S.", name))][2])
        aux <- filtered["COR"]
        percentage <- length(aux[aux["COR"] == as.character(cor)]) / nrow(filtered)
      }

      labels <- c(labels, htmltools::HTML(paste(
        sprintf(
          "<strong>%s</strong><br/>Vitimas: %g</sup><br/>Idade Média das Vitimas: %g</sup><br/>Raça/Cor com mais Vitimas: <strong>%s</strong> (%g",
          name,
          dens,
          round(idade, digits = 0),
          cor,
          round(as.numeric(percentage) * 100, digits = 2)
        ),
        "%)"
      )))
      density <- c(density, dens)
    }


    stateShape$labels <- labels
    stateShape$density <- density
    bins <- c(0, 2, 4, 8, 16, 32, 64, 128, Inf)
    pal <-
      colorBin("YlOrRd", domain = stateShape$density, bins = bins)

    leafletProxy("statemap") %>%
      clearGroup("densidade") %>%
      clearMarkers() %>%
      addPolygons(
        color = "#444444",
        data = stateShape,
        weight = 0.5,
        smoothFactor = 0.5,
        opacity = 1.0,
        fillOpacity = 0.8,
        fillColor = ~ pal(density),
        label = lapply(labels, htmltools::HTML),
        group = "densidade"
      )
  }
  
  

  deal_with_circle_marks <- function(filtered_data) {
    labels <- apply(filtered_data, 1, f)
    filtered_data_with_label <- filtered_data

    filtered_data_with_label$labels <- with(
      filtered_data,
      paste(
        "<p>Data do Ocorrido:",
        DATA_FATO,
        "</br>",
        "Genero: ",
        SEXO_PESSOA,
        "</br>",
        "Idade: ",
        IDADE_PESSOA,
        "</br>",
        "Cor: ",
        COR,
        "</br>",
        "Profissão: ",
        DESCR_PROFISSAO,
        "</br>",
        "</p>"
      )
    )

    leafletProxy("statemap") %>%
      clearGroup("densidade") %>%
      clearMarkers() %>%
      addCircleMarkers(
        data = filtered_data_with_label,
        popup = ~labels,
        lng = ~LONGITUDE,
        lat = ~LATITUDE,
        stroke = F,
        radius = 5,
        color = "#054880",
        fillOpacity = 0.9,
        group = "pointmarker"
      )
  }


  observeEvent(input$filterbtn, {
    if (input$mapgroupment == "mun") {
      if (input$corgroupment == "all") {
        filtered <-
          df[df["ANO_BO"] >= as.numeric(input$mapyear[1]) &
            df["ANO_BO"] <= as.numeric(input$mapyear[2]), ]
        deal_with_agrouped_clorophet(filtered)
      } else if (input$corgroupment == "pp") {
        filtered <-
          df[df["ANO_BO"] >= as.numeric(input$mapyear[1]) &
            df["ANO_BO"] <= as.numeric(input$mapyear[2]), ]
        filtered <-
          filtered[filtered["COR"] == "Preta" | filtered["COR"] == "Parda", ]
        deal_with_agrouped_clorophet(filtered)
      } else if (input$corgroupment == "ba") {
        filtered <-
          df[df["ANO_BO"] >= as.numeric(input$mapyear[1]) &
            df["ANO_BO"] <= as.numeric(input$mapyear[2]), ]
        filtered <-
          filtered[filtered["COR"] == "Branca" |
            filtered["COR"] == "Amarela", ]
        deal_with_agrouped_clorophet(filtered)
      } else {
        filtered <-
          df[df["ANO_BO"] >= as.numeric(input$mapyear[1]) &
            df["ANO_BO"] <= as.numeric(input$mapyear[2]), ]
        filtered <-
          filtered[filtered["COR"] == "NÃO INFORMADO" |
            filtered["COR"] == "Ignorada" | filtered["COR"] == "Outros", ]
        deal_with_agrouped_clorophet(filtered)
      }
    } else {
      if (input$corgroupment == "all") {
        filtered <-
          df[df["ANO_BO"] >= as.numeric(input$mapyear[1]) &
            df["ANO_BO"] <= as.numeric(input$mapyear[2]), ]
        deal_with_circle_marks(filtered)
      } else if (input$corgroupment == "pp") {
        filtered <-
          df[df["ANO_BO"] >= as.numeric(input$mapyear[1]) &
            df["ANO_BO"] <= as.numeric(input$mapyear[2]), ]
        filtered <-
          filtered[filtered["COR"] == "Preta" | filtered["COR"] == "Parda", ]
        deal_with_circle_marks(filtered)
      } else if (input$corgroupment == "ba") {
        filtered <-
          df[df["ANO_BO"] >= as.numeric(input$mapyear[1]) &
            df["ANO_BO"] <= as.numeric(input$mapyear[2]), ]
        filtered <-
          filtered[filtered["COR"] == "Branca" |
            filtered["COR"] == "Amarela", ]
        deal_with_circle_marks(filtered)
      } else {
        filtered <-
          df[df["ANO_BO"] >= as.numeric(input$mapyear[1]) &
            df["ANO_BO"] <= as.numeric(input$mapyear[2]), ]
        filtered <-
          filtered[filtered["COR"] == "NÃO INFORMADO" |
            filtered["COR"] == "Ignorada" | filtered["COR"] == "Outros", ]
        deal_with_circle_marks(filtered)
      }
    }
  })
}

shinyApp(ui, server)
