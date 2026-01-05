# Shiny App for HTML Checklist Generator

This Shiny application provides an interactive interface for generating HTML checklists.

> **Want to use the app online?** This app can be deployed to shinyapps.io for free! See the [Deployment Guide](DEPLOYMENT.md) for instructions.

## Features

- **Interactive File Upload**: Upload your items file (required) and optional metadata file
- **Live Preview**: See your checklist before downloading (with corrected CSS rendering)
- **Embedded Template**: Uses the default template automatically (no need to upload)
- **Customizable Settings**:
  - Custom title and subtitle
  - Color picker for default background and group colors
- **Data Validation**: Automatic validation of input files and groups
- **Activity Log**: Track all operations and errors
- **Shared Code Base**: Uses the same helper functions as the command-line script

## Requirements

The following R packages are required:

- `shiny` - Core Shiny framework
- `data.table` - Fast data reading
- `dplyr` - Data manipulation
- `DT` - Interactive tables
- `colourpicker` - Color picker widget
- `here` - Robust path handling (works from any working directory)
- `rsconnect` - For deploying to shinyapps.io (optional)

## Installation

Install the required packages by running (from the shiny_app directory):

```bash
cd shiny_app
Rscript install_shiny_packages.R
```

Or from the project root:

```bash
Rscript shiny_app/install_shiny_packages.R
```

Or manually in R:

```r
install.packages(c("shiny", "data.table", "dplyr", "DT", "colourpicker", "here", "rsconnect"))
```

## Running the App

**Note:** Thanks to the `here` package, the app works from any working directory!

### From the terminal (from project root):

```bash
cd shiny_app
R -e "shiny::runApp('app.R')"
```

Or directly:

```bash
R -e "shiny::runApp('shiny_app/app.R')"
```

### From an R session:

```r
shiny::runApp('shiny_app/app.R')
```

Or if already in the shiny_app directory:

```r
shiny::runApp('app.R')
```

The app will open in your default web browser.

## Public Deployment (Optional)

Want to share your app with others who don't have R installed?

Deploy to **shinyapps.io** for free! See [DEPLOYMENT.md](DEPLOYMENT.md) for complete instructions.

### Option 1: Automatic Deployment (Recommended)

Set up GitHub Actions to automatically deploy whenever you push changes:
- See [../.github/GITHUB_ACTIONS_SETUP.md](../.github/GITHUB_ACTIONS_SETUP.md) for setup instructions
- Once configured, just push your changes and the app updates automatically

### Option 2: Manual Deployment

**Quick deploy:**
```r
source("shiny_app/deploy_to_shinyapps.R")
```

Once deployed, share the URL with anyone:
```
https://your-account.shinyapps.io/html-checklist-generator/
```

## Usage

1. **Upload Items File** (Required):
   - Tab-separated file with columns: `Item` and `Group`
   - Example: `../example_input/items.tab`

2. **Upload Metadata File** (Optional):
   - Tab-separated file with columns: `Color` and `Group`
   - Example: `../example_input/metadata.tab`

3. **Customize Settings** (Optional):
   - Set title and subtitle
   - Choose default colors
   - Set output filename

4. **Generate Checklist**:
   - Click "Generate Checklist" button
   - Preview the result in the Preview tab

5. **Download**:
   - Click "Download HTML" to save your checklist

## File Format

### Items File (Required)

Tab-separated file with two columns:

```
Item	Group
First task	Category1
Second task	Category2
Third task	Category1
```

### Metadata File (Optional)

Tab-separated file with two columns:

```
Group	Color
Category1	#1b9e77
Category2	#d95f02
```

Colors should be in hexadecimal format (e.g., `#1b9e77`).

## Tabs

- **Preview**: View the generated HTML checklist
- **Items Data**: View uploaded items in a table
- **Metadata**: View uploaded metadata in a table
- **Log**: View activity log and error messages

## Notes

- The items file is mandatory; all other inputs are optional
- Empty group names will be assigned to "DEFAULT_CLASS"
- If no metadata file is provided, default colors will be used
- The HTML template is embedded in the app (uses the same template as `html_template/Checklist_template.html`)
- Helper functions are shared between the Shiny app and command-line script via `checklist_helpers.R`
- The preview in the app has been optimized to display correctly (legend above the checklist instead of side-by-side)
- **Path handling:** The `here` package ensures the app works correctly regardless of your current working directory

## Project Structure

The project now uses a modular structure to avoid code duplication:

- `checklist_helpers.R` - Shared helper functions (in project root)
- `shiny_app/app.R` - Shiny application (sources via `here::here("checklist_helpers.R")`)
- `create_checklist.R` - Command-line script (sources via `here::here("checklist_helpers.R")`)
- `html_template/Checklist_template.html` - Template used by command-line script
  - Note: The same template is embedded in `shiny_app/app.R` for the Shiny app

The `here` package is used for robust path handling, allowing scripts to work from any working directory.
