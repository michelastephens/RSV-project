# Load necessary libraries
library(dplyr)        # For data manipulation and summarization
library(flextable)   # For creating tables in Word documents
library(here)        # For managing file paths

# Set the working directory for the R script
here::i_am("code/02_wellvisitcalc.R")  # Defines the script's location for file path resolution

# Read the dataset from the output directory
b_wellvisit <- readRDS(file = here::here("output/b_wellvisit.rds"))  # Load well visit data
b_demographics <- readRDS(file = here::here("output/b_demographics.rds"))  # Load demographic data

# Ensure IDs are in character format for consistency across datasets
b_wellvisit$id <- as.character(b_wellvisit$id)
b_demographics$id <- as.character(b_demographics$id)

# Helper function to summarize total wellness visits per child
count_well_visits <- function(dataset) {
  dataset %>%
    group_by(id) %>%  # Group data by ID to summarize visits
    summarize(total_wellvisits = n(), .groups = 'drop') %>%  # Count total visits per ID
    full_join(b_demographics %>% select(id), by = "id") %>%  # Full join to include all IDs from demographics
    mutate(total_wellvisits = ifelse(is.na(total_wellvisits), 0, total_wellvisits))  # Replace NAs with 0 for missing visits
}

# Helper function to count well visits within 30 days from birth
count_well_visits_within_30_days <- function(wellvisit_data, demographic_data) {
  wellvisit_data %>%
    inner_join(demographic_data, by = "id") %>%  # Inner join to keep only matching IDs
    filter(difftime(wellVisit_date, birth_Date, units = "days") <= 30) %>%  # Filter visits within 30 days of birth
    group_by(id) %>%  # Group by ID for summarization
    summarize(well_visit_30days_count = n(), .groups = 'drop') %>%  # Count visits within 30 days per ID
    full_join(demographic_data %>% select(id), by = "id") %>%  # Full join to include all IDs
    mutate(well_visit_30days_count = ifelse(is.na(well_visit_30days_count), 0, well_visit_30days_count))  # Replace NAs with 0
}

# Calculate the required statistics
wellvisit_summary <- count_well_visits(b_wellvisit)  # Summary of total well visits
well_visits_within_30_days <- count_well_visits_within_30_days(b_wellvisit, b_demographics)  # Visits within 30 days

# Calculate the number of unique kids in the demographics dataset
num_unique_kids <- n_distinct(b_demographics$id)  # Count of unique IDs

# Create a list to hold the results
wellness_results <- list(
  num_unique_kids = num_unique_kids,  # Total unique kids
  wellvisit_summary = wellvisit_summary,  # Summary of total well visits
  wellvisit_within_30 = well_visits_within_30_days  # Summary of visits within 30 days
)

# Check for specific missing IDs in the wellvisit summary
missing_ids <- setdiff(b_demographics$id, wellvisit_summary$id)  # Identify missing IDs
print(missing_ids)  # Print missing IDs for debugging purposes

# Return the results list explicitly
wellness_results  # Output the results for further analysis
