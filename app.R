library(shiny)
library(jsonlite)
library(httr)
library(bslib)

# GitHub API URLs
github_base_url <- "https://raw.githubusercontent.com/natanast/TidyTuesday/main/"
github_api_url <- "https://api.github.com/repos/natanast/TidyTuesday/contents/Code"

# Function to get available folders (years & subfolders dynamically)
get_available_folders <- function(api_url) {
    res <- GET(api_url)
    
    if (status_code(res) == 200) {
        contents <- fromJSON(content(res, as = "text"))
        years <- contents$name  # Get year folder names (e.g., "2024", "2025")
        
        all_folders <- c()
        all_dates <- c()  # Store extracted dates
        for (year in years) {
            year_url <- paste0(api_url, "/", year)
            year_res <- GET(year_url)
            
            if (status_code(year_res) == 200) {
                subfolders <- fromJSON(content(year_res, as = "text"))$name  # Extract dataset folder names
                
                for (subfolder in subfolders) {
                    path <- paste0("Code/", year, "/", subfolder, "/plot.png")
                    all_folders <- c(all_folders, path)
                    all_dates <- c(all_dates, subfolder)  # Extract just the date part
                }
            }
        }
        
        # Return as a named vector: Choices are full paths, but labels are dates
        return(setNames(all_folders, all_dates))
    } else {
        return(NULL)
    }
}

# Get all available images dynamically
available_images <- get_available_folders(github_api_url)

# UI
ui <- page_sidebar(
    title = div(h3("📊 TidyTuesday Contributions", style = "color: #ededed; text-align: center; 
                   margin-bottom: 1px; margin-top: 1px; font-size: 35px;")),
    
    sidebar = sidebar(
        selectInput(
            inputId = "dataset",
            label = "Select Dataset:",
            choices = available_images,
            selected = ifelse(length(available_images) > 0, available_images[14], NULL)
        )
    ),
    
    navset_underline(
        
        # About 
        nav_panel(
            title = tags$h5("About", style = "color: #456f82; margin-bottom: 5px;"),
            fluidPage(
                br(),
                div(style = "max-width: 1000px; margin: auto;", 
                    card(
                        full_screen = FALSE, fill = TRUE,
                        style = "padding: 20px; box-shadow: 2px 2px 10px rgba(0,0,0,0.1);",
                        card_body(
                            h4("About This App", style = "font-size: 26px; font-weight: bold; color: #456f82"),
                            p("This Shiny app displays my contributions to the TidyTuesday project.", style = "font-size: 22px;"),
                            p("Use the dropdown menu to select a dataset and view the corresponding visualization at the Plot tab.", style = "font-size: 22px;"),
                            p("All images are fetched dynamically from my GitHub repository.", style = "font-size: 22px;"),
                            hr(),
                            h5("📌 TidyTuesday", style = "font-size: 26px; font-weight: bold; color: #456f82"),
                            p("TidyTuesday is a weekly data visualization challenge where participants analyze and visualize publicly available datasets.", style = "font-size: 22px;"),
                            a("Learn more about TidyTuesday", 
                              href = "https://github.com/rfordatascience/tidytuesday", 
                              target = "_blank", 
                              style = "font-size: 20px; color: #456f82; text-decoration: none;")
                        )
                    )
                )
            )
        ),
        
        # Plot 
        nav_panel(
            title = tags$h5("Plot", style = "color: #456f82; margin-bottom: 5px;"),
            fluidPage(
                br(),
                div(style = "display: flex; justify-content: center;",  # Center card
                    card(
                        full_screen = TRUE, fill = FALSE,
                        style = "width: 950px; padding: 10px; box-shadow: 2px 2px 10px rgba(0,0,0,0.1);",
                        card_body(uiOutput("image_display"))
                    )
                )
            )
        )

        
    ),
    
    theme = bs_theme(
        preset = "cerulean",
        bg = "#f1f1f1",
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
