# Load in libraries
library(shiny)
library(bslib)
library(tools)
library(readxl)
library(dplyr)

# Load helper functions
source('helpers.R')

# List of desired column names. Will be used by removeExtraHeaders()
desired_col_name <- c("Profile", "Game", "Credits",	"MINUTES", "TPT")

# Define UI for application that takes in an .xslx file, creates some summary
# tables and allows user to create a theoretical store tpt
ui <- fluidPage(
  
  # App title 
  titlePanel("TPT Adjustment Calculator"),
  
  # Input: Select a file 
  fileInput(
    "upload",
    "Upload weekly TPT report",
    multiple = FALSE,
    accept = c(
      ".xlsx"
    )
  ),
  
  fluidRow(
    
    # Output: summary statistics
    column(width = 4,
           tableOutput("report"),
    ),
    
    # Adjusting store tpt by selecting game and typing in desired tpt
    # for that game
    column(width = 5,
           helpText("Select a game you want to adjust. Then type new tpt",
                    "value. The program will compute a new theoretical store average"),
           
           selectInput("gametoadjust",
                       "Select game",
                       choices = NULL,
                       multiple = FALSE),
           card(
             card_header("Current TPT:"),
             textOutput("currenttpt")
           ),
           
           numericInput("newtpt",
                        "New TPT",
                        value = NULL,
                        width = '25%',
                        min = 0,
                        max = 6,
                        step = .1)
    ),
    
    column(width = 3,
           card(
             card_header("New Theoretical TPT:"),
             textOutput("theoreticaltpt"))
    )
  ),
  
  # Output: Top 5 Highest and Top 5 Lowest TPT
  fluidRow(
    column(width = 6,
           helpText("Top 5 Highest and Top 5 Lowest TPT"),
           tableOutput("badtpts")
    ),
    # Output: Top 10 Games With Largest Impact on Average TPT
    column(width = 6,
           helpText("Top 10 Games With Largest Impact on Average TPT"),
           tableOutput("badtptsweighted")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  data <- reactive({
    req(input$upload)
    filepath <- input$upload$datapath
    dataset <- removeExtraHeaders(filepath, 
                                  desired_col = desired_col_name,
                                  rm_sums_row = TRUE)
    # Add weighted TPT column to data frame (weighted by times played)
    grand_total_plays <- sum(dataset$`Total Plays`)
    dataset <- dataset %>%
      mutate(`Weighted TPT` = abs((TPT - mean(TPT)) * 
                                    (`Total Plays` / grand_total_plays)))
  })
  
  # Update game choices for adjusting tpt
  observeEvent(data(), {
    choices <- data() %>%
      arrange(desc(`Weighted TPT`)) %>%
      select(Game)
    updateSelectInput(inputId = "gametoadjust", choices = choices)
  })
  
  # Output: display current tpt of selected game
  output$currenttpt <- renderText({
    req(input$gametoadjust)
    
    selected_game_tpt <- data()[data()$Game == input$gametoadjust, ]$TPT
    return(selected_game_tpt)
  })
  
  # Output: new theoretical tpt based on user input
  output$theoreticaltpt <- renderText({
    req(input$gametoadjust)
    req(input$newtpt)
    
    new_data <- data()
    
    # Adjust game tpt to user selected value
    game <- new_data[new_data$Game == input$gametoadjust, ]$Game
    
    new_data[new_data$Game == game, "TICKETS"] <- 
      new_data[new_data$Game == game, "Total Plays"] * input$newtpt
    
    new_store_tpt <- round(tpt_summary(new_data)$values[6],3)
    return(new_store_tpt)
  })
  
  # Output: summary statistics table 
  output$report <- renderTable({
    
    return(tpt_summary(data()))
  }, rownames = TRUE, colnames = FALSE)
  
  # Output: table of most extreme tpts for redemption games
  output$badtpts <- renderTable({
    
    greatest_tpt <- data() %>%
      select(Game, TPT, `Total Plays`) %>%
      arrange(desc(TPT)) %>%
      head(5)
    smallest_tpt <- data() %>%
      filter(TicketProfile == "Redemption") %>%
      select(Game, TPT, `Total Plays`) %>%
      arrange(TPT) %>%
      head(5)
    
    return(bind_rows(greatest_tpt, smallest_tpt))
  })
  
  # Output: table of most extreme weighted tpts for redemption games
  # Weighted by times played
  output$badtptsweighted <- renderTable({
    
    greatest_weighted_tpt <- data() %>%
      select(Game, TPT, `Total Plays`, `Weighted TPT`) %>%
      arrange(desc(`Weighted TPT`)) %>%
      head(5)
    smallest_weighted_tpt <- data() %>%
      filter(TicketProfile == "Redemption" & TPT < 3) %>%
      select(Game, TPT, `Total Plays`, `Weighted TPT`) %>%
      arrange(desc(`Weighted TPT`)) %>%
      head(5)
    
    #return(greatest_weighted_tpt)
    return(bind_rows(greatest_weighted_tpt, smallest_weighted_tpt))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
