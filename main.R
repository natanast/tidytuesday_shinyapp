library(shiny)


# data

# front end interface
ui <- fluidPage(
    
    titlePanel(
        "TidyTuesday Contributions"
    ),
    
    sidebarLayout(
        sidebarPanel(
            selectInput(
                inputId = "dataset",
                label = "Select Dataset:",
                choices = NULL
            )
        ),
        mainPanel(
            uiOutput("image_display") # Dynamically render the selected image
        )
    )
)

    
# back end logic
server <- function(input, output, session) {
    
    
    
}

shinyApp(ui, server)

