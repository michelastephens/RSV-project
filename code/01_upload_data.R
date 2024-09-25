# Set the working directory for the R script
here::i_am("code/01_upload_data.R")

# Load necessary libraries
library(dplyr)  # For data manipulation
library(readxl)  # For reading Excel files
library(here)  # For file path management

# Read datasets from XLSX files into R
b_demographics <- readxl::read_excel(here::here("data/b_demog_2024.09.10.xlsx"))  # Demographics data
b_wellvisit <- readxl::read_excel(here::here("data/b_wellvisit_2024.09.10.xlsx"))  # Wellness visit data
b_NirsevimabImmu <- readxl::read_excel(here::here("data/b_NirsevimabImmu_2024.09.10.xlsx"))  # Immunization data
b_NirsevimabOutPT <- readxl::read_excel(here::here("data/b_NirsevimabOutPT_2024.09.10.xlsx"))  # Outpatient medication data
b_RSV <- readxl::read_excel(here::here("data/b_RSV_2024.09.10.xlsx"))  # procedure data

# Save each dataset as .rds file for later use
saveRDS(b_demographics, file = here::here("output/b_demographics.rds"))  # Save demographics data
saveRDS(b_wellvisit, file = here::here("output/b_wellvisit.rds"))  # Save wellness visit data
saveRDS(b_NirsevimabImmu, file = here::here("output/b_NirsevimabImmu.rds"))  # Save immunization data
saveRDS(b_NirsevimabOutPT, file = here::here("output/b_NirsevimabOutPT.rds"))  # Save outpatient medication data
saveRDS(b_RSV, file = here::here("output/b_RSV.rds"))  # Save procedure data

# Check structure of each dataset to understand the data types and format
str(b_demographics)
str(b_wellvisit)
str(b_NirsevimabImmu)
str(b_NirsevimabOutPT)
str(b_RSV)

# Check for ID duplicates before merging datasets
sum(duplicated(b_demographics$id))  # Count duplicates in demographics data
sum(duplicated(b_wellvisit$id))  # Count duplicates in well visit data
sum(duplicated(b_NirsevimabImmu$id))  # Count duplicates in immunization data
sum(duplicated(b_NirsevimabOutPT$id))  # Count duplicates in outpatient medication data
sum(duplicated(b_RSV$id))  # Count duplicates in procedure data

# Ensure 'id' is of the same type (character) across all datasets to facilitate merging
b_demographics$id <- as.character(b_demographics$id)
b_wellvisit$id <- as.character(b_wellvisit$id)
b_NirsevimabImmu$id <- as.character(b_NirsevimabImmu$id)
b_NirsevimabOutPT$id <- as.character(b_NirsevimabOutPT$id)
b_RSV$id <- as.character(b_RSV$id)

# Check for missing data in the 'id' column of each dataset
sum(is.na(b_demographics$id))  # Count missing IDs in demographics
sum(is.na(b_wellvisit$id))  # Count missing IDs in well visit data
sum(is.na(b_NirsevimabImmu$id))  # Count missing IDs in immunization data
sum(is.na(b_NirsevimabOutPT$id))  # Count missing IDs in outpatient medication data
sum(is.na(b_RSV$id))  # Count missing IDs in procedure data

# Merge datasets using left joins, keeping all records from demographics and adding corresponding data from other datasets
merged_data <- left_join(b_demographics, b_wellvisit, by = "id")  # Merge demographics with well visits
merged_data <- left_join(merged_data, b_NirsevimabImmu, by = "id")  # Add immunization data
merged_data <- left_join(merged_data, b_NirsevimabOutPT, by = "id")  # Add outpatient medication data
merged_data <- left_join(merged_data, b_RSV, by = "id")  # Add procedure data

# Create the final dataset with the required components by summarizing merged data
final_dataset <- merged_data %>%
  group_by(id) %>%  # Group by 'id' for aggregation
  summarize(
    birth_date = first(birth_Date),  # Extract the first birth date for each child
    total_well_visits = n_distinct(wellVisit_date, na.rm = TRUE),  # Count distinct well visit dates
    visits_within_30_days = sum(wellVisit_date <= (birth_date + 30), na.rm = TRUE),  # Count visits within 30 days of birth
    received_rsv_vaccine = ifelse(any(!is.na(Nirsevimab_immune_date)), 1, 0),  # Check if RSV vaccine was received (1 = Yes, 0 = No)
    rsv_vaccine_date = ifelse(any(!is.na(Nirsevimab_immune_date)), 
                              format(as.POSIXct(max(Nirsevimab_immune_date, na.rm = TRUE), origin = "1970-01-01"), "%Y-%m-%d"),  # Get the latest RSV vaccine date in "YYYY-MM-DD" format
                              NA),  # If no vaccine date, return NA
    
    # Update references to medication_name and PROC_NAME with binary indicators
    records_from_immunization = ifelse(any(!is.na(Nirsevimab_immune_date)), 1, 0),  # Check for records from immunization (1 = Yes, 0 = No)
    records_from_medication = ifelse(any(!is.na(MEDICATION_NAME)), 1, 0),  # Check for records from medication (1 = Yes, 0 = No)
    records_from_procedure = ifelse(any(!is.na(PROC_NAME)), 1, 0),  # Check for records from procedure (1 = Yes, 0 = No)
    
    # Calculate total RSV records ensuring it cannot exceed 3
    total_rsv_records = (ifelse(any(!is.na(Nirsevimab_immune_date)), 1, 0) +  # Count if there is an RSV vaccine record
                           ifelse(any(!is.na(MEDICATION_NAME)), 1, 0) +  # Count if there is a medication record
                           ifelse(any(!is.na(PROC_NAME)), 1, 0))  # Count if there is a procedure record
  )

# Save the final dataset as an .rds file for further analysis
saveRDS(final_dataset, file = here::here("output/final_dataset.rds"))

# Check the structure and dimensions of the final dataset for verification
str(final_dataset)  # Check the structure of the final dataset
nrow(final_dataset)  # Get the number of rows in the final dataset

