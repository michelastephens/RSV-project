# Load necessary libraries
library(officer)  # For creating and editing Word documents
library(flextable)  # For creating tables in Word documents
library(here)  # For managing file paths

# Load individual scripts to access calculated results
wellvisit_results <- source(here::here("code/02_wellvisitcalc.R"))$value  # Load wellness visit results
vaccination_results <- source(here::here("code/03_RSVVxcalc.R"))$value  # Load RSV vaccination results
final_data <- source(here::here("code/01_upload_data.R"))$value  # Load final dataset

# Create a new Word document
doc <- read_docx()  # Initialize a new Word document

# Access results correctly

# 1. Number of Wellness Visits Per Kid
doc <- doc %>%
  body_add_par("Number of Wellness Visits Per Kid", style = "heading 1") %>%  # Add section heading
  body_add_flextable(flextable(wellvisit_results$wellvisit_summary %>%  # Create a table from wellness visit summary
                                 mutate(id = as.character(id))) %>%  # Convert ID to character for consistency
                       set_header_labels(id = "Child ID", total_wellvisits = "Total Wellness Visits") %>%  # Set header labels
                       set_table_properties(width = 0.75, layout = "autofit") %>%  # Set table properties
                       theme_vanilla())  # Apply a vanilla theme to the table

# 2. Number of Wellness Visits Within 30 Days from Birth
doc <- doc %>%
  body_add_par("Number of Wellness Visits Within 30 Days from Birth", style = "heading 1") %>%  # Add section heading
  body_add_flextable(flextable(wellvisit_results$wellvisit_within_30 %>%  # Create a table for wellness visits within 30 days
                                 mutate(id = as.character(id))) %>%  # Convert ID to character
                       set_header_labels(id = "Child ID", 
                                         well_visit_30days_count = "Wellness Visits Within 30 Days") %>%  # Set header labels
                       set_table_properties(width = 0.75, layout = "autofit") %>%  # Set table properties
                       theme_vanilla())  # Apply a vanilla theme to the table

# 3. Number of Babies Who Received RSV Vaccine
doc <- doc %>%
  body_add_par("Number of Babies Who Received RSV Vaccine", style = "heading 1") %>%  # Add section heading
  body_add_par(paste("Total number of babies who received RSV vaccine:", vaccination_results$num_babies_vx), style = "Normal")  # Add total count of babies vaccinated

# 4. Among Babies Who Had RSV Vaccine, How Many Received Vaccine Within 7 Days
doc <- doc %>%
  body_add_par("Babies Who Received RSV Vaccine Within 7 Days of Birth", style = "heading 1") %>%  # Add section heading
  body_add_par(paste("Total babies vaccinated within 7 days of birth:", vaccination_results$num_babies_within_7_days), style = "Normal")  # Add total count of babies vaccinated within 7 days

# 5. Babies with RSV Vaccine Records from Immunization, Medication, and Procedure Forms
doc <- doc %>%
  body_add_par("Number of Babies Who Had RSV Vaccine", style = "heading 1") %>%  # Add section heading
  body_add_par(paste("Total number of babies who had RSV vaccine from all three sources (immunization, medication, procedure):", 
                     vaccination_results$num_babies_with_all_records), 
               style = "Normal")  # Add total count from all sources

# Count the number of babies with RSV records for each source
num_babies_with_rsv_immunization <- sum(vaccination_results$rsv_records$records_from_immunization == "Yes")  # Count from immunization records
num_babies_with_rsv_medication <- sum(vaccination_results$rsv_records$records_from_medication == "Yes")  # Count from medication records
num_babies_with_rsv_procedure <- sum(vaccination_results$rsv_records$records_from_procedure == "Yes")  # Count from procedure records

# Document the counts in the Word document
doc <- doc %>%
  body_add_par(paste("Number of babies with RSV vaccine documented in Immunization records:", 
                     num_babies_with_rsv_immunization), 
               style = "Normal") %>%  # Add count for immunization records
  body_add_par(paste("Number of babies with RSV vaccine documented in Medication records:", 
                     num_babies_with_rsv_medication), 
               style = "Normal") %>%  # Add count for medication records
  body_add_par(paste("Number of babies with RSV vaccine documented in Procedure records:", 
                     num_babies_with_rsv_procedure), 
               style = "Normal")  # Add count for procedure records

# Save the Word document
print(doc, target = here::here("output/final_report.docx"))  # Export the document to the specified path

# Save final data set as a CSV file
write.csv(final_dataset, file = here::here("output/final_dataset.csv"), row.names = FALSE)  # Save final dataset to CSV
