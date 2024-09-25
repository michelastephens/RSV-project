# RSV Project Organization and GitHub Repository

This repository contains code and data for the RSV project, aimed at analyzing wellness visits and vaccination data for infants.

## Repository Structure

### Code Directory

- `code/01_upload_data.R`: Loads datasets from Excel files, saves as `.rds` objects, checks structure and duplicates.
- `code/02_wellvisitcalc.R`: Analyzes wellness visit data, counts visits per child, calculates visits within 30 days, exports results to Word.
- `code/03_RSVVxcalc.R`: Analyzes vaccination data, identifies infants receiving the RSV vaccine, creates visualizations and tables.
- `code/04_compile_report.R`: Compiles results from previous analyses, generates the final report, and generates final dataset. 

### Project Goals

- Analyze wellness visit data and vaccination rates among infants.
- Provide a data table summarizing findings.
- Ensure reproducibility by organizing code and data clearly.

### Report

- `final_report.docx`: Compiles tables and figures, providing a comprehensive report with key findings.

### Data Directory

- `data/`: Contains raw datasets used for analysis.
- `code/`: Contains r script code needed to clean and filter the data.
- `output/`: Contains processed datasets and analysis results.

### Variable Descriptions

In the final dataset, the following binary-coded variables are included:

- `records_from_immunization`: Indicates if the RSV vaccine record is from immunization sources (0 = No, 1 = Yes).
- `records_from_medication`: Indicates if the RSV vaccine record is from medication sources (0 = No, 1 = Yes).
- `records_from_procedure`: Indicates if the RSV vaccine record is from procedure sources (0 = No, 1 = Yes).
- `received_rsv_vaccine`: Indicates if the infant received the RSV vaccine (0 = No, 1 = Yes).

### Getting Started

1. Clone the repository.
2. Run scripts in the `code/` directory sequentially.
