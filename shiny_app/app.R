suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(here))

# --------------------------- #
# Load Helper Functions       #
# --------------------------- #

# Try to source from local directory first (for shinyapps.io deployment)
# If not found, source from parent directory (for local development)
if (file.exists("checklist_helpers.R")) {
  source("checklist_helpers.R")
} else {
  source(here::here("checklist_helpers.R"))
}

# --------------------------- #
# Embedded HTML Template      #
# --------------------------- #

get_html_template <- function() {
  '<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Checklist</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <!-- Load Roboto Mono from Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:wght@400;500&display=swap" rel="stylesheet">

  <style>
    :root {
      --bg: #f0f4f8;
      --card-bg: #ffffff;
      --accent: --bg_color--;
      --accent-light: --bg_color_faded--;
      --text: #333;
      --muted: #888;
    }

    body {
      font-family: \'Roboto Mono\', monospace;
      background: linear-gradient(135deg, #fff7fb, #9ecae1);
      margin: 0;
      padding: 2rem;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
    }

    .checklist-container {
      background: var(--card-bg);
      padding: 2rem;
      border-radius: 20px;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
      width: 100%;
      max-width: 600px;
      transition: all 0.3s ease;
    }

    h1 {
      text-align: center;
      color: var(--accent);
      margin-bottom: 0.3rem;
      font-size: 2rem;
    }

    .subtitle {
      text-align: center;
      color: var(--muted);
      font-size: 1rem;
      margin-bottom: 1.5rem;
    }

    .checklist-item {
      display: flex;
      align-items: center;
      margin-bottom: 1rem;
      padding: 0.75rem 1rem;
      border-radius: 12px;
      background: var(--accent-light);
      transition: background 0.3s, transform 0.2s;
    }

    
    --item_hover--

    input[type="checkbox"] {
      width: 1.3rem;
      height: 1.3rem;
      margin-right: 1rem;
      accent-color: var(--accent);
      transition: all 0.2s ease;
    }

    .checked label {
      text-decoration: line-through;
      color: var(--muted);
    }

    label {
      font-size: 1.1rem;
      cursor: pointer;
      flex: 1;
      transition: color 0.3s;
    }

    @media (max-width: 600px) {
      .checklist-container {
        padding: 1.5rem;
      }
    }

.layout {
  display: flex;
  align-items: flex-start;
  gap: 30px;
  font-family: sans-serif;
}


  /* ---------------- */
  /* Customize legend */
  /* ---------------- */
  
  /* Sticky + vertically centered legend */
  .legend {
    position: sticky;
    top: 50%;
    transform: translateY(-50%);
    align-self: flex-start;
    min-width: 250px;
    background: white;
    padding: 1rem;
    border-radius: 15px;
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
    font-family: sans-serif;
    height: fit-content;
    z-index: 10;
    margin-right: 80px;
  }



  
  .legend-item {
    display: flex;
    align-items: center;
    margin-bottom: 8px;
  }

  .color-box {
    width: 16px;
    height: 16px;
    display: inline-block;
    margin-right: 8px;
    border-radius: 3px;
  }
  
  --colorbox_bg--
  


  /* ------------------- */
  /* Customize checklist */
  /* ------------------- */
  
  .checklist-item {
    padding: 10px;
    margin: 5px 0;
    border-radius: 5px;
  }
  
  --checklist_style--

  /* ------------ */
  /* Reset button */
  /* ------------ */
  
  .reset-btn {
    display: inline-block;
    margin: 0.5rem 0 1.5rem;
    padding: 0.5rem 1rem;
    font-size: 1rem;
    font-family: inherit;
    color: #fff;
    background: var(--accent);
    border: none;
    border-radius: 8px;
    cursor: pointer;
    transition: background 0.2s;
  }
  
  .reset-btn:hover {
    background: #574dff;        /* slightly darker accent */
  }


  /* ------------ */
  /* Progress bar */
  /* ------------ */
  
  .progress-container {
    width: 100%;
    height: 20px;
    background-color: #e0e0e0;
    border-radius: 10px;
    overflow: hidden;
    margin-bottom: 1rem;
  }
  
  .progress-bar {
    height: 100%;
    width: 0%;
    background-color: var(--accent);
    transition: width 0.3s ease;
  }
  
  .progress-text {
    text-align: right;
    font-size: 0.9rem;
    color: var(--muted);
    margin-bottom: 1.5rem;
    font-family: \'Roboto Mono\', monospace;
  }

  </style>
</head>
<body>

<div class="legend">
  <div class="progress-container">
    <div class="progress-bar" id="progressBar"></div>
  </div>
  <div class="progress-text" id="progressText">0% completed</div>

  --legend_div--
  
<!--
  <div class="legend-item"><span class="color-box prepare_pipeline"></span> Prepare Pipeline</div>
-->

</div>
  
  <div class="checklist-container">

    <h1>--title--</h1>
    <div class="subtitle">--subtitle--</div>
    <button id="resetBtn" class="reset-btn" type="button">Reset all</button>
    <div class="checklist">

    --checklist_buttons--

<!--
      <div class="checklist-item">
        <input type="checkbox" id="item1">
        <label for="item1">Verify disk space availability</label>
      </div>
-->      
      
    </div>
  </div>

<script>
  const runID = document.getElementById("runID")?.dataset.run || "defaultRun";

  const makeKey = id => `${runID}_${id}`;

  const checkboxes = document.querySelectorAll(\'.checklist-item input[type="checkbox"]\');
  const progressBar = document.getElementById(\'progressBar\');
  const progressText = document.getElementById(\'progressText\');

  function updateProgress() {
    const total = checkboxes.length;
    const checked = Array.from(checkboxes).filter(cb => cb.checked).length;
    const percent = total === 0 ? 0 : Math.round((checked / total) * 100);
    progressBar.style.width = `${percent}%`;
    progressText.textContent = `${percent}% completed`;
  }

  // Initialize checklist
  checkboxes.forEach((checkbox) => {
    const id = checkbox.id;
    const saved = localStorage.getItem(makeKey(id));

    if (saved === "true") {
      checkbox.checked = true;
      checkbox.parentElement.classList.add("checked");
    }

    checkbox.addEventListener(\'change\', () => {
      localStorage.setItem(makeKey(id), checkbox.checked);
      checkbox.parentElement.classList.toggle("checked", checkbox.checked);
      updateProgress();
    });
  });

  // Reset button logic
  document.getElementById(\'resetBtn\')?.addEventListener(\'click\', () => {
    checkboxes.forEach((checkbox) => {
      localStorage.removeItem(makeKey(checkbox.id));
      checkbox.checked = false;
      checkbox.parentElement.classList.remove("checked");
    });
    updateProgress();
  });

  // Call once on load to reflect saved state
  updateProgress();
</script>


</body>
</html>'
}

# --------------------------- #
# UI Definition               #
# --------------------------- #

ui <- fluidPage(
  titlePanel("HTML Checklist Generator"),
  
  # Add custom CSS to fix preview rendering
  tags$head(
    tags$style(HTML("
      /* Override Shiny's default styles for better preview rendering */
      #preview .legend {
        position: relative !important;
        top: auto !important;
        transform: none !important;
        margin-bottom: 20px;
        margin-right: 0px;
      }
      
      #preview body {
        display: block !important;
        min-height: auto !important;
      }
      
      #preview .layout {
        flex-direction: column;
      }
    "))
  ),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      
      # Mandatory file input
      fileInput("items_file", 
                "Items File (Required)*",
                accept = c(".tab", ".tsv", ".txt"),
                placeholder = "Tab-separated file with Item and Group columns"),
      
      helpText("Required columns: 'Item' and 'Group'"),
      
      hr(),
      
      # Optional inputs
      h4("Optional Settings"),
      
      fileInput("metadata_file",
                "Metadata File (Optional)",
                accept = c(".tab", ".tsv", ".txt"),
                placeholder = "Tab-separated file with Color and Group columns"),
      
      helpText("Optional columns: 'Color' and 'Group'"),
      
      textInput("title", "Title", value = "My Checklist"),
      
      textInput("subtitle", "Subtitle", value = ""),
      
      colourpicker::colourInput("default_bg_color", 
                                "Default Background Color", 
                                value = "#6c63ff"),
      
      colourpicker::colourInput("default_group_color", 
                                "Default Group Color", 
                                value = "#e6ab02"),
      
      textInput("output_filename", 
                "Output Filename", 
                value = "checklist.html"),
      
      hr(),
      
      actionButton("generate", "Generate Checklist", 
                   class = "btn-primary btn-lg btn-block"),
      
      br(),
      
      downloadButton("download", "Download HTML", 
                     class = "btn-success btn-block")
    ),
    
    mainPanel(
      width = 9,
      
      tabsetPanel(
        tabPanel("Preview",
                 br(),
                 uiOutput("preview_info"),
                 hr(),
                 htmlOutput("preview")
        ),
        
        tabPanel("Items Data",
                 br(),
                 DT::dataTableOutput("items_table")
        ),
        
        tabPanel("Metadata",
                 br(),
                 DT::dataTableOutput("metadata_table")
        ),
        
        tabPanel("Log",
                 br(),
                 verbatimTextOutput("log")
        )
      )
    )
  )
)

# --------------------------- #
# Server Logic                #
# --------------------------- #

server <- function(input, output, session) {
  
  # Reactive values to store data
  rv <- reactiveValues(
    items_df = NULL,
    metadata_df = NULL,
    html_content = NULL,
    log_messages = character(0)
  )
  
  # Helper function to add log messages
  add_log <- function(msg) {
    rv$log_messages <- c(rv$log_messages, paste0("[", Sys.time(), "] ", msg))
  }
  
  # Read items file
  observeEvent(input$items_file, {
    tryCatch({
      req(input$items_file)
      
      rv$items_df <- fread(input$items_file$datapath)
      
      # Validate columns
      expected.cols <- c('Item', 'Group')
      df.contains.cols(df = rv$items_df, expected.cols = expected.cols)
      
      # Fill empty group names
      rv$items_df$Group[rv$items_df$Group == ""] <- "DEFAULT_CLASS"
      
      add_log(paste("Items file loaded successfully:", 
                    nrow(rv$items_df), "items"))
      
      showNotification("Items file loaded successfully!", 
                       type = "message", duration = 3)
      
    }, error = function(e) {
      add_log(paste("ERROR loading items file:", e$message))
      showNotification(paste("Error loading items file:", e$message), 
                       type = "error", duration = 5)
      rv$items_df <- NULL
    })
  })
  
  # Read metadata file
  observeEvent(input$metadata_file, {
    tryCatch({
      req(input$metadata_file)
      
      rv$metadata_df <- fread(input$metadata_file$datapath)
      
      # Validate columns
      expected.cols <- c('Color', 'Group')
      df.contains.cols(df = rv$metadata_df, expected.cols = expected.cols)
      
      # Add DEFAULT_CLASS
      rv$metadata_df <- rbind(rv$metadata_df, 
                              data.frame(Color = input$default_group_color, 
                                        Group = "DEFAULT_CLASS"))
      
      rv$metadata_df$Color <- ifelse(rv$metadata_df$Color == "", 
                                     yes = input$default_group_color, 
                                     no = rv$metadata_df$Color)
      
      add_log(paste("Metadata file loaded successfully:", 
                    nrow(rv$metadata_df), "groups"))
      
      showNotification("Metadata file loaded successfully!", 
                       type = "message", duration = 3)
      
    }, error = function(e) {
      add_log(paste("ERROR loading metadata file:", e$message))
      showNotification(paste("Error loading metadata file:", e$message), 
                       type = "error", duration = 5)
      rv$metadata_df <- NULL
    })
  })
  
  # Generate checklist
  observeEvent(input$generate, {
    tryCatch({
      req(rv$items_df)
      
      add_log("Starting checklist generation...")
      
      # Get embedded template
      template_content <- strsplit(get_html_template(), "\n")[[1]]
      
      # Validate groups if metadata exists
      if (!is.null(rv$metadata_df)) {
        validate.groups(items = rv$items_df, meta = rv$metadata_df)
        add_log("Groups validated successfully")
      }
      
      # Prepare checklist content
      items.groups.pairs <- fill.items.groups(items = rv$items_df$Item,
                                              groups = rv$items_df$Group)
      
      items.vector  <- items.groups.pairs[['items']]
      groups.vector <- items.groups.pairs[['groups']]
      
      # Generate HTML components
      checklist.terms <- list()
      
      # Title and subtitle
      checklist.terms[['--title--']] <- input$title
      checklist.terms[['--subtitle--']] <- input$subtitle
      
      # Color categories (CSS)
      if (!is.null(rv$metadata_df)) {
        css.colorbox.bg.output <- generate_colorbox_legend_html(
          groups = rv$metadata_df$Group,
          colors = rv$metadata_df$Color
        )
      } else {
        css.colorbox.bg.output <- ""
      }
      checklist.terms[['--colorbox_bg--']] <- css.colorbox.bg.output
      
      # Item styles
      if (!is.null(rv$metadata_df)) {
        css.item.style.output <- generate_checklist_style_html(
          groups = rv$metadata_df$Group,
          colors = rv$metadata_df$Color,
          alphas = fade_hex_color(rv$metadata_df$Color, alpha = 0.25)
        )
      } else {
        css.item.style.output <- ""
      }
      checklist.terms[['--checklist_style--']] <- css.item.style.output
      
      # Hover effects
      if (!is.null(rv$metadata_df)) {
        hover.js <- generate_checklist_item_hover(
          groups = rv$metadata_df$Group,
          colors = rv$metadata_df$Color
        )
      } else {
        hover.js <- paste0('.checklist-item:hover {
          background: ', input$default_bg_color,' !important;
          transform: scale(1.01);
        }')
      }
      checklist.terms[['--item_hover--']] <- hover.js
      
      # Generate checklist entries
      html.output <- generate_checklist_html(
        checklist = rev(items.vector),
        categories = rev(groups.vector)
      )
      checklist.terms[['--checklist_buttons--']] <- html.output
      
      # Legend
      if (!is.null(rv$metadata_df)) {
        legend.div.output <- generate_legend_div_html(groups = rv$metadata_df$Group)
      } else {
        legend.div.output <- ""
      }
      checklist.terms[['--legend_div--']] <- legend.div.output
      
      # Background colors
      checklist.terms[['--bg_color--']] <- input$default_bg_color
      checklist.terms[['--bg_color_faded--']] <- fade_hex_color(input$default_bg_color, 
                                                                 alpha = 0.25)
      
      # Fill template
      for (t in names(checklist.terms)) {
        template_content <- gsub(x = template_content,
                                pattern = t,
                                replacement = checklist.terms[[t]],
                                ignore.case = TRUE, perl = TRUE)
      }
      
      rv$html_content <- paste(template_content, collapse = "\n")
      
      add_log("Checklist generated successfully!")
      showNotification("Checklist generated successfully!", 
                       type = "message", duration = 3)
      
    }, error = function(e) {
      add_log(paste("ERROR generating checklist:", e$message))
      showNotification(paste("Error generating checklist:", e$message), 
                       type = "error", duration = 5)
    })
  })
  
  # Display items table
  output$items_table <- DT::renderDataTable({
    req(rv$items_df)
    DT::datatable(rv$items_df, options = list(pageLength = 20))
  })
  
  # Display metadata table
  output$metadata_table <- DT::renderDataTable({
    req(rv$metadata_df)
    DT::datatable(rv$metadata_df, options = list(pageLength = 20))
  })
  
  # Display log
  output$log <- renderText({
    paste(rv$log_messages, collapse = "\n")
  })
  
  # Preview info
  output$preview_info <- renderUI({
    if (!is.null(rv$html_content)) {
      div(
        class = "alert alert-success",
        icon("check-circle"),
        strong(" Checklist generated successfully!"),
        " Use the download button to save the HTML file."
      )
    } else if (!is.null(rv$items_df)) {
      div(
        class = "alert alert-info",
        icon("info-circle"),
        " Items file loaded. Click 'Generate Checklist' to create your checklist."
      )
    } else {
      div(
        class = "alert alert-warning",
        icon("exclamation-triangle"),
        " Please upload an items file to begin."
      )
    }
  })
  
  # Preview HTML
  output$preview <- renderUI({
    req(rv$html_content)
    HTML(rv$html_content)
  })
  
  # Download handler
  output$download <- downloadHandler(
    filename = function() {
      input$output_filename
    },
    content = function(file) {
      req(rv$html_content)
      writeLines(rv$html_content, file)
      add_log(paste("Checklist downloaded:", input$output_filename))
    }
  )
}

# --------------------------- #
# Run the app                 #
# --------------------------- #

shinyApp(ui = ui, server = server)
