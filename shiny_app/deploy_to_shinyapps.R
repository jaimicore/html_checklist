# ========================================
# Deploy HTML Checklist Generator to shinyapps.io
# ========================================
#
# This script deploys your Shiny app to shinyapps.io
#
# FIRST TIME SETUP:
# 1. Create a free account at https://www.shinyapps.io/
# 2. Go to Account -> Tokens
# 3. Click "Show" and copy your token information
# 4. Run the setAccountInfo command below with your credentials
#
# ========================================

# Install rsconnect if needed
if (!require("rsconnect", quietly = TRUE)) {
  message("Installing rsconnect package...")
  install.packages("rsconnect")
}

library(rsconnect)

# ========================================
# STEP 1: Configure your shinyapps.io account (FIRST TIME ONLY)
# ========================================
# 
# Uncomment and fill in your information from https://www.shinyapps.io/admin/#/tokens
# 
# rsconnect::setAccountInfo(
#   name   = "YOUR-ACCOUNT-NAME",
#   token  = "YOUR-TOKEN",
#   secret = "YOUR-SECRET"
# )

# ========================================
# STEP 2: Check if account is configured
# ========================================

accounts <- rsconnect::accounts()

if (nrow(accounts) == 0) {
  stop("
  ERROR: No shinyapps.io account configured!
  
  Please:
  1. Go to https://www.shinyapps.io/ and create an account
  2. Go to Account -> Tokens
  3. Click 'Show' and copy your credentials
  4. Uncomment and fill in the setAccountInfo() section above
  5. Run this script again
  ")
} else {
  message("Account configured: ", accounts$name[1])
}

# ========================================
# STEP 3: Prepare files for deployment
# ========================================

message("\nPreparing to deploy...")

# Copy checklist_helpers.R from parent directory to shiny_app folder
# This is required for shinyapps.io deployment
helper_source <- here::here("checklist_helpers.R")
helper_dest <- here::here("shiny_app", "checklist_helpers.R")

if (file.exists(helper_source)) {
  file.copy(helper_source, helper_dest, overwrite = TRUE)
  message("Copied checklist_helpers.R for deployment")
} else {
  stop("ERROR: Cannot find checklist_helpers.R in project root!")
}

# Set working directory to shiny_app folder
setwd(here::here("shiny_app"))

# ========================================
# STEP 4: Deploy the app
# ========================================

# App name (customize if desired)
app_name <- "html-checklist-generator"

message("Deploying app to shinyapps.io...")
message("   App name: ", app_name)
message("   This may take a few minutes...")

# Deploy!
rsconnect::deployApp(
  appName = app_name,
  appTitle = "HTML Checklist Generator",
  forceUpdate = TRUE,
  launch.browser = TRUE
)

message("\nDeployment complete!")
message("Your app is now live at:")
message("   https://", accounts$name[1], ".shinyapps.io/", app_name, "/")
message("\nManage your app at: https://www.shinyapps.io/admin/#/applications")
