#!/usr/bin/env Rscript

# Tool Availability Matrix Validation Script
# Compares toolsets in chatmode.md files against the matrix in README.md

library(readr)
library(dplyr)
library(stringr)
library(yaml)

# Function to extract tools from YAML frontmatter (unique set)
extract_tools_from_chatmode <- function(file_path) {
  if (!file.exists(file_path)) {
    warning(paste("File not found:", file_path))
    return(character(0))
  }
  
  content <- readLines(file_path, warn = FALSE)
  
  # Find YAML frontmatter boundaries
  yaml_start <- which(content == "---")[1]
  yaml_end <- which(content == "---")[2]
  
  if (is.na(yaml_start) || is.na(yaml_end)) {
    warning(paste("No YAML frontmatter found in:", file_path))
    return(character(0))
  }
  
  yaml_content <- content[(yaml_start + 1):(yaml_end - 1)]
  yaml_text <- paste(yaml_content, collapse = "\n")
  
  # Parse YAML
  parsed_yaml <- yaml.load(yaml_text)
  
  if (is.null(parsed_yaml$tools)) {
    warning(paste("No tools found in:", file_path))
    return(character(0))
  }
  
  return(sort(unique(parsed_yaml$tools)))
}

# Function to extract tool availability matrix from README.md
extract_tool_matrix_from_readme <- function(readme_path = "README.md") {
  if (!file.exists(readme_path)) {
    stop("README.md not found")
  }
  
  content <- readLines(readme_path, warn = FALSE)
  
  # Find the Tool Availability Matrix section
  matrix_start <- grep("## Tool Availability Matrix", content)
  if (length(matrix_start) == 0) {
    stop("Tool Availability Matrix section not found in README.md")
  }
  
  # Find the table (lines starting with |)
  table_lines <- content[matrix_start:length(content)]
  table_start <- which(str_detect(table_lines, "^\\|"))[1]
  
  if (is.na(table_start)) {
    stop("Tool availability table not found")
  }
  
  # Extract table lines
  table_start_abs <- matrix_start + table_start - 1
  table_lines <- content[table_start_abs:length(content)]
  
  # Find end of table (first non-table line that's not empty)
  table_end <- which(!str_detect(table_lines, "^\\|") & str_trim(table_lines) != "")[1]
  if (is.na(table_end)) {
    table_end <- length(table_lines) + 1
  }
  
  table_lines <- table_lines[1:(table_end - 1)]
  
  # Remove only the markdown separator row (pipes, spaces, colons, hyphens)
  sep_idx <- str_detect(table_lines, "^\\|[ :\\-]+\\|$")
  table_lines <- table_lines[!sep_idx]
  
  if (length(table_lines) < 2) {
    stop("Insufficient table data found")
  }
  
  # Parse header
  header_line <- table_lines[1]
  headers <- str_split(header_line, "\\|")[[1]]
  headers <- str_trim(headers)
  headers <- headers[headers != ""]
  
  # Parse data rows and extract tool names
  data_rows <- table_lines[-1]
  tool_matrix <- data.frame()
  
  for (i in seq_along(data_rows)) {
    row <- data_rows[i]
    
    cells <- str_split(row, "\\|")[[1]]
    cells <- str_trim(cells)
    cells <- cells[cells != ""]
    
    if (length(cells) >= length(headers)) {
      # Extract tool name from first cell (remove markdown links and formatting)
      tool_name <- cells[1]
      
      # Skip section headers and empty rows
      if (str_detect(tool_name, "^\\*") || tool_name == "" || str_detect(tool_name, "^\\*\\*")) {
        next
      }
      
      # Extract tool name from markdown link [toolname](#link)
      if (str_detect(tool_name, "\\[.*\\]\\(.*\\)")) {
        extracted_name <- str_extract(tool_name, "(?<=\\[)[^\\]]+(?=\\])")
        if (!is.na(extracted_name)) {
          tool_name <- extracted_name
        }
        
      }
      
      if (tool_name != "" && !is.na(tool_name)) {
        row_data <- data.frame(
          Tool = tool_name,
          QnA = cells[2],
          Review = cells[3],
          Plan = cells[4], 
          Code = cells[5],
          stringsAsFactors = FALSE
        )
        tool_matrix <- rbind(tool_matrix, row_data)
      }
    }
  }
  
  return(tool_matrix)
}

# Function to convert tool matrix to expected toolsets per mode
convert_matrix_to_toolsets <- function(tool_matrix) {
  # The README has a single 'Code' column that applies to both Code chatmodes.
  # Similarly, a single 'Review' column applies to both Review chatmodes.
  base_modes <- c("QnA", "Review", "Plan", "Code")
  expected_toolsets <- list()

  for (mode in base_modes) {
    if (!mode %in% names(tool_matrix)) {
      warning(paste("Mode", mode, "not found in tool matrix"))
      next
    }

    mode_column <- tool_matrix[[mode]]
    has_tool <- str_detect(mode_column, "✅|✓|���") & !is.na(mode_column)
    mode_tools <- tool_matrix[has_tool, "Tool"]
    mode_tools <- mode_tools[!is.na(mode_tools)]
    mode_tools <- str_trim(mode_tools)
    mode_tools <- mode_tools[mode_tools != ""]

    expected_toolsets[[mode]] <- sort(unique(mode_tools))
  }

  # Duplicate the single Code column for both implementation-specific Code modes.
  if (!is.null(expected_toolsets[["Code"]])) {
    expected_toolsets[["Code-GPT5"]] <- expected_toolsets[["Code"]]
    expected_toolsets[["Code-Sonnet4"]] <- expected_toolsets[["Code"]]
  }

  # Duplicate the single Review column for both model-specific Review modes.
  if (!is.null(expected_toolsets[["Review"]])) {
    expected_toolsets[["Review-Gemini"]] <- expected_toolsets[["Review"]]
    expected_toolsets[["Review-GPT5"]] <- expected_toolsets[["Review"]]
  }

  return(expected_toolsets)
}

# Main validation function
validate_toolsets <- function() {
  cat("=== Tool Availability Matrix Validation ===\n\n")
  
  # Extract expected toolsets from README.md
  cat("Reading tool matrix from README.md...\n")
  tool_matrix <- extract_tool_matrix_from_readme()
  
  # Simple check for target tools
  if ("resolve-library-id" %in% tool_matrix$Tool && "get-library-docs" %in% tool_matrix$Tool) {
    cat("SUCCESS: Both target tools found in matrix!\n")
  } else {
    cat("ISSUE: Target tools missing from matrix\n")
    cat("Matrix contains", nrow(tool_matrix), "tools\n")
    cat("resolve-library-id present:", "resolve-library-id" %in% tool_matrix$Tool, "\n")
    cat("get-library-docs present:", "get-library-docs" %in% tool_matrix$Tool, "\n")
  }
  
  # Report duplicate tool rows in README matrix
  if ("Tool" %in% names(tool_matrix)) {
    dupes <- names(table(tool_matrix$Tool))[table(tool_matrix$Tool) > 1]
    if (length(dupes) > 0) {
      cat("WARNING: README matrix contains duplicated tool rows:", paste(dupes, collapse = ", "), "\n")
    }
  }
  
  expected_toolsets <- convert_matrix_to_toolsets(tool_matrix)
  
  # Debug: show expected toolsets
  cat("Debug: Expected toolsets:\n")
  for (mode in names(expected_toolsets)) {
    cat(paste("  ", mode, ":", length(expected_toolsets[[mode]]), "tools\n"))
    if (length(expected_toolsets[[mode]]) > 0) {
      cat(paste("    First few:", paste(head(expected_toolsets[[mode]], 3), collapse = ", "), "\n"))
    }
  }
  
  # Extract actual toolsets from chatmode files
  cat("Reading toolsets from chatmode.md files...\n")
  modes <- c("QnA", "Plan", "Review-Gemini", "Review-GPT5", "Code-GPT5", "Code-Sonnet4")
  actual_toolsets <- list()
  
  for (mode in modes) {
    file_path <- paste0("copilot/modes/", mode, ".chatmode.md")
    # Detect duplicated tools from raw YAML before deduping
    content <- readLines(file_path, warn = FALSE)
    yaml_start <- which(content == "---")[1]
    yaml_end <- which(content == "---")[2]
    if (!is.na(yaml_start) && !is.na(yaml_end) && yaml_end > yaml_start) {
      yaml_text <- paste(content[(yaml_start + 1):(yaml_end - 1)], collapse = "\n")
      parsed_yaml <- yaml.load(yaml_text)
      if (!is.null(parsed_yaml$tools)) {
        raw_tools <- unlist(parsed_yaml$tools)
        dupes <- names(table(raw_tools))[table(raw_tools) > 1]
        if (length(dupes) > 0) {
          cat(paste("WARNING:", mode, "mode chatmode.md contains duplicated tools:", paste(dupes, collapse = ", "), "\n"))
        }
        actual_toolsets[[mode]] <- sort(unique(raw_tools))
      } else {
        actual_toolsets[[mode]] <- character(0)
      }
    } else {
      actual_toolsets[[mode]] <- extract_tools_from_chatmode(file_path)
    }
  }
  
  # Debug: show actual toolsets
  cat("Debug: Actual toolsets:\n")
  for (mode in names(actual_toolsets)) {
    cat(paste("  ", mode, ":", length(actual_toolsets[[mode]]), "tools\n"))
    if (length(actual_toolsets[[mode]]) > 0) {
      cat(paste("    First few:", paste(head(actual_toolsets[[mode]], 3), collapse = ", "), "\n"))
      if ("get-library-docs" %in% actual_toolsets[[mode]]) {
        cat("    Contains get-library-docs: YES\n")
      }
      if ("resolve-library-id" %in% actual_toolsets[[mode]]) {
        cat("    Contains resolve-library-id: YES\n")
      }
    }
  }
  
  # Compare toolsets
  cat("\n=== Validation Results ===\n")
  all_valid <- TRUE
  
  for (mode in modes) {
    cat(paste("\n", mode, "Mode:\n"))
    
    expected <- expected_toolsets[[mode]]
    actual <- actual_toolsets[[mode]]
    
    if (is.null(expected) || length(expected) == 0) {
      cat("  ❌ No expected tools found in README.md matrix\n")
      all_valid <- FALSE
      next
    }
    
    if (is.null(actual) || length(actual) == 0) {
      cat("  ❌ No actual tools found in chatmode.md file\n")
      all_valid <- FALSE
      next
    }
    
    # Check for exact match
    if (setequal(expected, actual)) {
      cat("  ✅ Toolsets match perfectly\n")
      cat(paste("     Tool count:", length(actual), "\n"))
    } else {
      cat("  ❌ Toolsets do not match\n")
      all_valid <- FALSE
      
      # Show differences
      missing_tools <- setdiff(expected, actual)
      extra_tools <- setdiff(actual, expected)
      
      if (length(missing_tools) > 0) {
        cat("     Missing tools in chatmode.md:\n")
        for (tool in missing_tools) {
          cat(paste("       -", tool, "\n"))
        }
      }
      
      if (length(extra_tools) > 0) {
        cat("     Extra tools in chatmode.md:\n")
        for (tool in extra_tools) {
          cat(paste("       +", tool, "\n"))
        }
      }
      
      cat(paste("     Expected count:", length(unique(expected)), "\n"))
      cat(paste("     Actual count:", length(unique(actual)), "\n"))
    }
  }
  
  cat("\n=== Summary ===\n")
  if (all_valid) {
    cat("✅ All toolsets are valid and match the README.md matrix\n")
  } else {
    cat("❌ Some toolsets do not match the README.md matrix\n")
    cat("Please update either the chatmode.md files or the README.md matrix\n")
  }
  
  return(all_valid)
}

# Run validation
if (!interactive()) {
  result <- validate_toolsets()
  if (!result) {
    quit(status = 1)
  }
} else {
  validate_toolsets()
}
