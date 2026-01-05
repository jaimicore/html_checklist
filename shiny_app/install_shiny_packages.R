# Install required packages for the Shiny app
required_packages <- c("shiny", "DT", "colourpicker", "here", "rsconnect")

message("Installing packages for Shiny app...")
message("Note: rsconnect is included for optional deployment to shinyapps.io\n")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    message("Installing ", pkg, "...")
    install.packages(pkg, repos = "https://cloud.r-project.org/")
  } else {
    message("[OK] ", pkg, " is already installed")
  }
}

message("\nAll required packages are ready!")
message("\n" , paste(rep("=", 50), collapse = ""))
message("NEXT STEPS:")
message(paste(rep("=", 50), collapse = ""))
message("\n1. Run locally:")
message("   R -e \"shiny::runApp('shiny_app/app.R')\"")
message("\n2. Deploy to shinyapps.io (optional):")
message("   See shiny_app/QUICKSTART_DEPLOY.md")
message("   Or run: source('shiny_app/deploy_to_shinyapps.R')")
message("\n" , paste(rep("=", 50), collapse = ""))
