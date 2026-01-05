suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(optparse))

# --------------------------- #
# Load Helper Functions       #
# --------------------------- #

# Use here package for robust path handling
if (!require("here", quietly = TRUE)) {
  install.packages("here")
  library(here)
}

source(here::here("checklist_helpers.R"))


# --------------------------- #
# Read command-line arguments #
# --------------------------- #

option_list = list(
  
  make_option(c("-i", "--items_file"), type = "character", default = NULL, 
              help = "A tab-separated file with two expected columns ('Item' and 'Group'), where 'Item' corresponds to the text diplayed in the checklist and 'Group' to an assigned category. Mandatory argument."),
  
  make_option(c("-m", "--metadata_file"), type = "character", default = NULL, 
              help = "A tab-separated file with two expected columns ('Color' and 'Group'), where 'Color' corresponds to the hexadecimal colorcode assigned to each category 'Group'."),

  make_option(c("-t", "--checklist_template_file"), type = "character", default = NULL, 
              help = "The html document used as skeleton to create the interactive checklist, it is provided in the repository. Mandatory argument."),
  
  make_option(c("-o", "--output_file"), type = "character", default = NULL, 
              help = "Filepath to the created html document. Mandatory argument"),
  
  make_option(c("-c", "--default_bg_color"), type = "character", default = "#6c63ff", 
              help = "Default color for the list items. Overwritten when the metadata file is provided."),

  make_option(c("-g", "--default_group_color"), type = "character", default = "#e6ab02", 
              help = "Default category color. Overwritten when the metadata file is provided."),

  make_option(c("--title"), type = "character", default = "Default Title", 
              help = "Title displayed in the checklist."),
  
  make_option(c("--subtitle"), type = "character", default = "", 
              help = "Subtitle displayed in the checklist.")
);

message("; Reading arguments from command-line")
opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);


items.file       <- opt$items_file
metadata.file    <- opt$metadata_file
cl.template.file <- opt$checklist_template_file
cl.ready.file    <- opt$output_file
title.str        <- opt$title
subtitle.str     <- opt$subtitle
bg.color         <- opt$default_bg_color
group.color      <- opt$default_group_color

# items.file       <- "~/Documents/Repositories/InPreD_README/Checklist_code/example_input/items.tab"
# metadata.file    <- "~/Documents/Repositories/InPreD_README/Checklist_code/example_input/metadata.tab"
# cl.template.file <- "~/Documents/Repositories/InPreD_README/Checklist_code/html_template/Checklist_template.html"
# cl.ready.file    <- paste0("~/Documents/Repositories/InPreD_README/Checklist_code/", paste0("TEST_checklist_", date.checklist, ".html"))


# ------------------------ #
# Define default variables #
# ------------------------ #
checklist.terms  <- list()
date.checklist   <- Sys.time()
dir.create(dirname(cl.ready.file), showWarnings = FALSE, recursive = TRUE)


# ---------------- #
# Read input files #
# ---------------- #

# Verify valid column names
expected.items.columns <- c('Item', 'Group')

message("; Reading items from file: ", items.file)
items.df <- fread(items.file)
df.contains.cols(df = items.df, expected.cols = expected.items.columns)

# Fill empty group names
items.df$Group[items.df$Group == ""] <- "DEFAULT_CLASS"

# Validate metadata (if provided)
meta.exists <- !is.null(metadata.file)
if (meta.exists) {
  message("; Reading metadata from file: ", metadata.file)
  meta.df <- fread(metadata.file)
  meta.df <- rbind(meta.df, data.frame(Color = group.color, Group = "DEFAULT_CLASS"))
  meta.df$Color <- ifelse(meta.df$Color == "", yes = group.color, no = meta.df$Color)
  
  message("; Validating groups")
  validate.groups(items = items.df,
                  meta  = meta.df)
  
}



# ------------------------------- #
# Prepare CheckList section names #
# ------------------------------- #

## Copy template and read copy
invisible(file.copy(from      = cl.template.file,
                    to        = cl.ready.file,
                    overwrite = TRUE))
message("; Copying html template")


# -------------------------------------- #
# Prepare checklist content (HTML + CSS) #
# -------------------------------------- #
message("; Preparing checklist content")
items.groups.pairs <- fill.items.groups(items  = items.df$Item,
                                        groups = items.df$Group)

items.vector  <- items.groups.pairs[['items']]
groups.vector <- items.groups.pairs[['groups']]

# Color categories (CSS)
if (meta.exists) {
  css.colorbox.bg.output <- generate_colorbox_legend_html(groups = meta.df$Group,
                                                          colors = meta.df$Color)
} else {
  css.colorbox.bg.output <- ""
}

# Color categories legend (CSS)
if (meta.exists) {
  css.item.style.output <- generate_checklist_style_html(groups = meta.df$Group,
                                                         colors = meta.df$Color,
                                                         alphas = fade_hex_color(meta.df$Color, alpha = 0.25))
} else {
  css.item.style.output <- ""
}

# Hover
if (meta.exists) {
  hover.js <- generate_checklist_item_hover(groups = meta.df$Group,
                                            colors = meta.df$Color)
} else {
  hover.js <- paste0('.checklist-item:hover {
      background: ', bg.color,' !important;
      transform: scale(1.01);
    }')
}

# Generate CheckList entries
html.output <- generate_checklist_html(checklist  = rev(items.vector),
                                       categories = rev(groups.vector))


# Legend Div 
if (meta.exists) {
  legend.div.output <- generate_legend_div_html(groups = meta.df$Group)
} else {
  legend.div.output <- ""
}


# Placeholder list
checklist.terms[['--title--']]             <- title.str
checklist.terms[['--subtitle--']]          <- subtitle.str

checklist.terms[['--colorbox_bg--']]       <- css.colorbox.bg.output
checklist.terms[['--checklist_style--']]   <- css.item.style.output

checklist.terms[['--checklist_buttons--']] <- html.output
checklist.terms[['--legend_div--']]        <- legend.div.output
checklist.terms[['--item_hover--']]        <- hover.js


checklist.terms[['--bg_color--']]          <- bg.color
checklist.terms[['--bg_color_faded--']]    <- fade_hex_color(bg.color, alpha = 0.25)


# ----------------------- #
# Fill CheckList template #
# ----------------------- #
message("; Filling checklist template")
template.to.fill <- readLines(cl.ready.file)

for (t in names(checklist.terms)) {
  
  template.to.fill <- gsub(x           = template.to.fill,
                           pattern     = t,
                           replacement = checklist.terms[[t]],
                           ignore.case = T, perl = T)
} 

# Export ready-to-use CheckList
invisible(file.remove(cl.ready.file))
writeLines(text = template.to.fill,
           con  = cl.ready.file)
message("; Exported html checklist: ", cl.ready.file)


# https://clideo.com/account/projects
# https://ezgif.com/