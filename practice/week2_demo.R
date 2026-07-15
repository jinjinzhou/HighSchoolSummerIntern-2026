# ==========================================================================
# Week 2 demonstration: read one Dexcom G6 JSON file
# ==========================================================================

library(tidyverse)
library(jsonlite)
library(lubridate)

# Change this if the AI-READI dataset is stored somewhere else.
DATA_PATH <- paste0(
  "/Users/jinjinzhou/Library/CloudStorage/Box-Box/",
  "ai-readi/v3-mini/dataset"
)


# ---- 1. Read the CGM manifest --------------------------------------------

cgm_manifest <- read_tsv(
  file.path(DATA_PATH, "wearable_blood_glucose", "manifest.tsv"),
  show_col_types = FALSE
)


# ---- 2. Choose the first CGM file ----------------------------------------

example_row <- cgm_manifest |>
  slice_head(n = 1)

example_id <- example_row$person_id[[1]]

# Remove the first slash so the path can be joined to DATA_PATH.
relative_path <- sub("^/", "", example_row$glucose_filepath[[1]])
cgm_file <- file.path(DATA_PATH, relative_path)

message("Reading CGM data for participant ", example_id)


# ---- 3. Read the JSON file -----------------------------------------------

cgm_json <- fromJSON(cgm_file, flatten = TRUE)

# A Dexcom file has a header and a body.
names(cgm_json)
cgm_json$header

# The header may contain a short label such as "pst". This is not enough
# to establish the participant's geographic timezone or daylight-saving
# rules, so this demonstration keeps all timestamps in UTC.
message(
  "Source timezone label: ", cgm_json$header$timezone,
  "; timestamps will remain in UTC."
)


# ---- 4. Extract the glucose readings -------------------------------------

cgm_readings <- cgm_json$body$cgm |>
  as_tibble()

glimpse(cgm_readings)
head(cgm_readings)


# ---- 5. Keep the columns needed for the example outputs -----------------


# ---- 6. Example output: CGM quality-control table ------------------------


# Remove missing, duplicate, and implausible readings for this exercise.
# The 40–400 mg/dL range is a simple demonstration rule.



# ---- 7. Example output: participant-day feature table --------------------

# A complete 5-minute CGM day has about 288 readings.
# For this exercise, at least 202 readings means at least 70% coverage.



# ---- 8. Example output: participant-level feature table ------------------



# ---- 9. Example output: full CGM trace ----------------------------------




# ---- 10. Example output: one-day CGM trace -------------------------------




# ---- 11. Example output: UTC-based 24-hour profile ----------------------

# A clinical AGP should use a confirmed participant/device local timezone.
# This UTC version demonstrates the plotting method only and should not be
# interpreted as local meal, sleep, or time-of-day behavior.

agp_data <- cgm_valid |>
  mutate(hour_bin_utc = floor(hour_utc * 4) / 4) |>
  group_by(hour_bin_utc) |>
  summarise(
    glucose_p25 = quantile(glucose_mgdl, 0.25),
    glucose_p50 = quantile(glucose_mgdl, 0.50),
    glucose_p75 = quantile(glucose_mgdl, 0.75),
    .groups = "drop"
  )

