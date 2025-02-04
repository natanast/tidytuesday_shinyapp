library(shiny)
library(jsonlite)
library(httr)
library(bslib)

# GitHub API URL to fetch all years
github_base_url <- "https://raw.githubusercontent.com/natanast/TidyTuesday/main/"
github_api_url <- "https://api.github.com/repos/natanast/TidyTuesday/contents/R"

# Function to get available folders (years & subfolders dynamically)
get_available_folders <- function(api_url) {
    res <- GET(api_url)
    
    if (status_code(res) == 200) {
        contents <- fromJSON(content(res, as = "text"))
        years <- contents$name  # Get year folder names (e.g., "2024", "2025")
        
        all_folders <- c()
        for (year in years) {
            year_url <- paste0(api_url, "/", year)
            year_res <- GET(year_url)
            
            if (status_code(year_res) == 200) {
                subfolders <- fromJSON(content(year_res, as = "text"))$name  # Extract dataset folder names
                subfolder_paths <- paste0("R/", year, "/", subfolders, "/Rplot.png")
                all_folders <- c(all_folders, subfolder_paths)
            }
        }
        return(all_folders)
    } else {
        return(NULL)  # Return NULL if API call fails
    }
}

# Get all available images dynamically
available_images <- get_available_folders(github_api_url)

# UI
ui <- page_sidebar(
    title = h3("📊 TidyTuesday Contributions", style = "color: #F3F6FA; margin-bottom: 5px;"),
    
    sidebar = sidebar(
        selectInput(
            inputId = "dataset",
            label = "Select Dataset:",
            choices = available_images,
            selected = ifelse(length(available_images) > 0, available_images[1], NULL)
        )
    ),
    
    navset_underline(
        nav_panel(
            title = tags$h6("Plot", style = "color: #004164; margin-bottom: 5px;"),
            fluidPage(
                br(),
                div(style = "display: flex; justify-content: center;",  # Center card
                    card(
                        full_screen = FALSE, fill = FALSE,
                        style = "width: 600px; padding: 10px; box-shadow: 2px 2px 10px rgba(0,0,0,0.1);",
                        card_body(uiOutput("image_display"))
                    )
                )
            )
        )
    ),
    
    theme = bs_theme(
        preset = "cerulean",
        bg = "#F3F6FA",
        fg = "#456f82",
        base_font = font_google("Jost")
    )
)

# Server
server <- function(input, output, session) {
    # Dynamically render the selected image
    output$image_display <- renderUI({
        req(input$dataset)  # Ensure input is available
        img_src <- paste0(github_base_url, input$dataset)
        tags$img(src = img_src, alt = "TidyTuesday Contribution", 
                 style = "max-width: 100%; height: auto; display: block; margin: auto;")
    })
}

shinyApp(ui, server)
