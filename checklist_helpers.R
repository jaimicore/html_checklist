# ===================================================================
# Helper Functions for HTML Checklist Generation
# ===================================================================
# This file contains shared functions used by both create_checklist.R
# and the Shiny app (app.R)
# ===================================================================

# Check if user-defined groups are the same in items and metadata
validate.groups <- function(items = NULL,
                            meta  = NULL) {
  
  items.groups <- unique(as.vector(items$Group))
  meta.groups  <- unique(as.vector(meta$Group))
  
  # All groups in the item table must have an assigned color in the metadata file
  # If false, then stop
  if(!all(items.groups %in% meta.groups) ) {
    stop("A group defined in the items file is not defined in the metadata")
  }
}


make_prepender <- function(prefix_name) {
  function(label, v) {
    c(label, v)
  }
}


# Create a pair of vectors containing the items and groups
fill.items.groups <- function(items  = NULL,
                              groups = NULL) {
  
  # Init checklist
  add.cl.item  <- make_prepender("item")
  add.cl.group <- make_prepender("group")
  
  # Checklist section names
  cl.items  <- vector()
  cl.groups <- vector()
  
  for (i in items){
    cl.items <- add.cl.item(i, cl.items)
  }
  
  for (g in groups){
    cl.groups <- add.cl.group(g, cl.groups)
  }
  
  
  return(list(items  = cl.items,
              groups = cl.groups))
}


# This function creates the <div> blocks, one per item in the list
# checklist  : the text that will appear in the in the checklist
# categories : the name of the html classes assigned to each item (each class has a different color)
generate_checklist_html <- function(checklist, categories) {
  if (length(checklist) != length(categories)) {
    stop("Checklist and categories must have the same length.")
  }
  
  html_items <- mapply(function(item, i, category) {
    sprintf(
      '<div class="checklist-item %s">\n  <input type="checkbox" id="item%d">\n  <label for="item%d">%d. %s</label>\n</div>',
      category, i, i, i, item
    )
  }, checklist, seq_along(checklist), categories, USE.NAMES = FALSE)
  
  paste(html_items, collapse = "\n")
}


# Creates the CSS code to style the boxes (<div>) in the checklist
# Creates a .checklist-item block of code with the style to each group
# Two colors are required, the color displayed in the box margin and faded version of the same color
# displayed as the box color
generate_checklist_style_html <- function(groups, colors, alphas) {
  
  if (!(length(groups) == length(colors) &&
        length(colors) == length(alphas))) {
    stop("groups, colors, and alphas must have the same length.")
  }
  
  html_items <- mapply(
    function(group, color, alpha) {
      sprintf(
        '.checklist-item.%s {
          background-color: %s;
          border-left: 4px solid %s;
        }',
        group, alpha, color
      )
    },
    groups, colors, alphas,
    USE.NAMES = FALSE
  )
  
  paste(html_items, collapse = "\n")
}


# Generate hover styles for checklist items
generate_checklist_item_hover <- function(groups, colors) {
  
  if (!(length(groups) == length(colors))) {
    stop("groups and colors must have the same length.")
  }
  
  html_items <- mapply(
    function(group, color) {
      sprintf(
        '.checklist-item.%s:hover {
          background-color: %s;
        }',
        group, color
      )
    },
    groups, colors,
    USE.NAMES = FALSE
  )
  
  paste(html_items, collapse = "\n")
}


# This function creates the text in the legend
# Creates a <div> for each group and assign a class for styling
generate_legend_div_html <- function(groups) {
  
  # Do not show DEFAULT_CLASS in legend
  groups <- groups[groups != "DEFAULT_CLASS"]
  
  html_items <- mapply(
    function(group) {
      sprintf(
        '<div class="legend-item"><span class="color-box %s"></span> %s</div>',
        group, group
      )
    },
    groups,
    USE.NAMES = FALSE
  )
  
  paste(html_items, collapse = "\n")
}


# Helping function to fade (add transparency) to any color in hexcode
# Returns the hexcode of the input color after applying the given transparency (alpha) value
fade_hex_color <- function(hex, alpha = 0.5) {
  # Recycle inputs to common length
  n <- max(length(hex), length(alpha))
  hex   <- rep(hex,   length.out = n)
  alpha <- rep(alpha, length.out = n)
  
  # Validate alpha
  if (!is.numeric(alpha) || any(is.na(alpha)) || any(alpha < 0 | alpha > 1)) {
    stop("alpha must be numeric values between 0 and 1.")
  }
  
  # Convert hex to RGB (returns 3 x n matrix)
  rgb <- grDevices::col2rgb(hex)
  
  # Alpha channel as hex
  alpha_hex <- sprintf("%02X", round(alpha * 255))
  
  # Build faded hex colors
  sprintf(
    "#%02X%02X%02X%s",
    rgb[1, ], rgb[2, ], rgb[3, ], alpha_hex
  )
}


# Colorbox background color (CSS)
# Assign colors to the classes (displayed in the legend)
generate_colorbox_legend_html <- function(groups, colors) {
  
  if (length(groups) != length(colors)) {
    stop("Checklist and categories must have the same length.")
  }
  
  html_items <- mapply(function(groups, colors) {
    sprintf(
      '.color-box.%s {
          background-color: %s;
       }',
      groups, colors
    )
  }, groups, colors, USE.NAMES = FALSE)
  
  paste(html_items, collapse = "\n")
}


# Validate that a dataframe contains expected columns
df.contains.cols <- function(df            = NULL,
                             expected.cols = NULL) {
  if (!all(expected.cols %in% colnames(df))) {
    stop("The DataFrame does not contain at least one of the expected columns: ", paste0(expected.cols, collapse = ", "))
  }
}
