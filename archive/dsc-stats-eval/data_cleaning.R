# ================================================
# DSC Data Cleaning and Merging Script (clean.R)
# ================================================

# Load necessary libraries
library(dplyr)
library(readr)
library(stringr)
library(janitor)
library(lubridate)
library(tidyr)

# --------------------------------
# Load Standardization Map
# --------------------------------
source("standardize_map.R")  # Ensure this file is in the working directory

# --------------------------------
# Load Datasets
# --------------------------------

# Workshops Data: Includes external workshops and in-house training
dsc_workshops <- read_csv('data/dsc_workshops.csv', na = c("N/A", "", "NA")) 
dsc_workshops <- dsc_workshops %>%
  mutate(status = str_replace_all(status, regex("(?i)graduate student|grad student|grad\\. student"), "Graduate Student"))

# Calendly Data: Data for scheduled consultations
dsc_calendly <- read_csv('data/libinsights-full21-24-dataframe.csv')

# DataSquad Sign-in Data
dsquad_sign_in <- read_csv('data/datasquad-sign-in.csv')

# Trello Data: Data for projects from Trello board
dsquad_trello <- read_csv('data/ucla-datasquad-projects-trello.csv')

# --------------------------------
# Clean and Process Calendly Data
# --------------------------------

# Clean variable names
dsc_calendly <- clean_names(dsc_calendly)

# Define DSC and Datasquad members for grouping
dsc_members <- c("Jamie Jamison", "Tim Dennis", "Doug Daniels", "Ali, Ibraheem", 
                 "Leigh Phan", "Zhiyuan Yao", "Gillian Bailey", "Kristian Allen",
                 "Zhiyuan (Jee-Wan) Yao")

datasquad_members <- c("JULIA WOOD", "KEONA MAE PABLO", "WILLIAM FOOTE", "deleted", 
                       "EMILY GONG", "Vincenty Front", "Shail Mirpuri", "Tristan Dewing", 
                       "Vince Front", "Lawrence Lee", "Hyerin Lee", "LORETTA HU", 
                       "LUKAS HAGER", "AIMEE XU", "Aditya Bharath")

# Select only specified columns and rename them for clarity
dsc_calendly <- dsc_calendly %>% 
  select(start_date_time, location, response_1, response_2, response_3, user_name) %>% 
  rename(department = response_1,
         ucla_affiliation = response_2,
         appointment_reason = response_3) %>% 
  mutate(group = case_when(
    user_name %in% dsc_members ~ "DSC",
    user_name %in% datasquad_members ~ "Datasquad",
    TRUE ~ "Other"
  ))

# --------------------------------
# Clean DataSquad Sign-in Data
# --------------------------------

dsquad_sign_in <- clean_names(dsquad_sign_in)

dsquad_sign_in <- dsquad_sign_in %>% 
  select(timestamp, format, department, year,
         what_topic_do_you_need_help_with_today)

# Clean the 'year' field by removing ordinal suffixes (e.g., "st", "nd", "rd", "th")
dsquad_sign_in$year <- gsub("\\s+\\d+(st|nd|rd|th)$", "", dsquad_sign_in$year)

# Rename columns to match Calendly data
dsquad_sign_in <- dsquad_sign_in %>%
  rename(
    start_date_time = timestamp,
    ucla_affiliation = year,
    appointment_reason = what_topic_do_you_need_help_with_today,
    location = format
  ) %>% 
  mutate(group = "Datasquad",
         user_name = "DataSquad Walk-in")

# Convert start_date_time to proper datetime format
dsquad_sign_in$start_date_time <- mdy_hms(dsquad_sign_in$start_date_time)

# --------------------------------
# Clean Trello Data
# --------------------------------

dsquad_trello <- dsquad_trello %>%
  clean_names()

# Expand rows based on comment_count; creates one row per comment instance
trello_expanded <- dsquad_trello %>%
  uncount(comment_count, .id = "instance")

# Select and rename necessary columns from Trello data
trello_subset <- trello_expanded %>%
  mutate(location = NA_character_) %>%
  select(start_date_time = last_activity_date, location, 
         department, 
         ucla_affiliation, 
         appointment_reason = card_description, 
         user_name = members) %>%
  mutate(group = "Datasquad")

# --------------------------------
# Combine Datasets for Consultations
# --------------------------------

dsc_consult <- bind_rows(dsc_calendly, dsquad_sign_in, trello_subset)

# Save the merged consultation data for later use
saveRDS(dsc_consult, "data/dsc_consult_merged.rds")

# --------------------------------
# Standardize Department Names
# --------------------------------

# Function to standardize department names using the standardize_map
standardize_dept <- function(dept) {
  if (is.na(dept) || dept == "") {
    return(NA_character_)
  } else {
    dept <- str_trim(dept)           # Trim whitespace
    dept <- str_to_lower(dept)         # Convert to lower case
    standardized <- standardize_map[[dept]]
    if (is.null(standardized)) {
      return(NA_character_)
    } else {
      return(standardized)
    }
  }
}

# Apply the standardization function to the 'department' column
dsc_consult <- dsc_consult %>%
  mutate(department = vapply(department, standardize_dept, character(1)))

# Save the standardized data for future use
saveRDS(dsc_consult, "data/dsc_consult_standardized.rds")

# --------------------------------
# Additional Processing
# --------------------------------

# Additional filtering, analysis, or transformation code can be added below.