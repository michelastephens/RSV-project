# Set the working directory for the R script
here::i_am("code/03_RSVVxcalc.R")  # Defines the script's location for accurate file path management

# Load necessary libraries
library(dplyr)  # For data manipulation and summarization

# Helper function to get unique IDs from a dataset
get_unique_ids <- function(dataset) {
  dataset %>%
    distinct(id) %>%  # Select distinct IDs to avoid duplicates
    pull(id)  # Extract IDs as a vector
}

# Helper function to combine datasets
combine_datasets <- function(...) {
  bind_rows(...) %>%  # Combine multiple datasets into one
    distinct()  # Ensure all IDs are unique to avoid duplicates
}

# 3. Number of Babies Who Had RSV Vaccine
# Combine datasets that contain RSV vaccine information
combined_rsv_data <- combine_datasets(
  select(b_NirsevimabImmu, id),  # Select IDs from immunization dataset
  select(b_NirsevimabOutPT, id),  # Select IDs from outpatient dataset
  select(b_RSV, id)  # Select IDs from procedure dataset
)

# Count distinct babies who received the RSV vaccine
num_babies_rsv_vx <- combined_rsv_data %>%
  summarize(num_babies_rsv_vx = n()) %>%  # Count total unique IDs
  pull(num_babies_rsv_vx)  # Extract the count directly

# 4. Among Babies Who Had RSV Vaccine, How Many Received the Vaccine Within 7 Days of Birth
# Helper function to combine RSV data with vaccination dates
combine_rsv_with_dates <- function() {
  combine_datasets(
    select(b_NirsevimabImmu, id, Nirsevimab_immune_date),  # Include immune date from immunization dataset
    select(b_NirsevimabOutPT, id, Nirsevimab_immune_date),  # Include immune date from outpatient dataset
    select(b_RSV, id, Nirsevimab_immune_date)  # Include immune date from procedure dataset
  )
}

# Step 1: Combine datasets containing RSV vaccination dates
combined_rsv_data_with_dates <- combine_rsv_with_dates()

# Convert id columns to character for consistency
combined_rsv_data_with_dates$id <- as.character(combined_rsv_data_with_dates$id)
b_demographics$id <- as.character(b_demographics$id)

# Step 2: Join combined RSV data with demographics to check vaccination dates
rsv_check_dates <- inner_join(combined_rsv_data_with_dates, b_demographics, by = "id") %>%
  mutate(days_difference = as.numeric(difftime(Nirsevimab_immune_date, birth_Date, units = "days"))) %>%  # Calculate days difference
  filter(days_difference <= 7)  # Filter for those who received the vaccine within 7 days

# Step 3: Count the total number of babies who received the vaccine within 7 days
num_babies_within_7_days <- nrow(rsv_check_dates)  # Count rows in the filtered dataset

# 5. Count the number of babies with RSV vaccine documented in each dataset
num_babies_rsv_vx_immunization <- length(get_unique_ids(b_NirsevimabImmu))  # Unique IDs from immunization dataset
num_babies_rsv_vx_outpatient <- length(get_unique_ids(b_NirsevimabOutPT))  # Unique IDs from outpatient dataset
num_babies_rsv_vx_procedure <- length(get_unique_ids(b_RSV))  # Unique IDs from procedure dataset

# Create a summary of RSV records
rsv_records <- data.frame(
  id = unique(c(get_unique_ids(b_NirsevimabImmu), 
                get_unique_ids(b_NirsevimabOutPT), 
                get_unique_ids(b_RSV)))  # Combine unique IDs from all sources
)

# Ensure consistent naming of columns and vectors
rsv_records <- rsv_records %>%
  mutate(
    records_from_immunization = ifelse(id %in% get_unique_ids(b_NirsevimabImmu), "Yes", "No"),  # Immunization records
    records_from_medication = ifelse(id %in% get_unique_ids(b_NirsevimabOutPT), "Yes", "No"),  # Outpatient records
    records_from_procedure = ifelse(id %in% get_unique_ids(b_RSV), "Yes", "No")  # Procedure records
  )

# Create a summary of results
vaccination_results <- list(
  num_babies_vx = num_babies_rsv_vx,  # Total babies vaccinated
  num_babies_within_7_days = num_babies_within_7_days,  # Babies vaccinated within 7 days
  num_babies_rsv_vx_immunization = num_babies_rsv_vx_immunization,  # Count from immunization dataset
  num_babies_rsv_vx_outpatient = num_babies_rsv_vx_outpatient,  # Count from outpatient dataset
  num_babies_rsv_vx_procedure = num_babies_rsv_vx_procedure,  # Count from procedure dataset
  rsv_records = rsv_records  # Include RSV records in results
)

# Store the results in the global environment
vaccination_results  # Output the results for further analysis
