

library(shiny)

# Define the GitHub raw content base URL
github_base_url <- "https://raw.githubusercontent.com/natanast/TidyTuesday/main/"

# Manually list available folders containing the `Rplot.png`
available_folders <- c(
    "R/2024/2024-05-21",
    "R/2024/2024-08-06"
)

# Construct full paths to the `Rplot.png` images
available_images <- paste0(available_folders, "/Rplot.png")

# Front-end interface
ui <- fluidPage(
    titlePanel("TidyTuesday Contributions"),
    sidebarLayout(
        sidebarPanel(
            selectInput(
                inputId = "dataset",
                label = "Select Dataset:",
                choices = available_images,
                selected = available_images[1]
            )
        ),
        mainPanel(
            uiOutput("image_display") # Dynamically render the selected image
        )
    )
)

# Back-end logic
server <- function(input, output, session) {
    # Dynamically render the selected image
    output$image_display <- renderUI({
        selected_image <- input$dataset
        # Combine GitHub raw URL base with the selected image path
        img_src <- paste0(github_base_url, selected_image)
        tags$img(src = img_src, alt = "TidyTuesday Contribution", style = "max-width: 100%; height: auto;")
    })
}



shinyApp(ui, server)
