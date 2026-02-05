# ================================================
# Text Analysis Script (text_analysis.R)
# ================================================
# This script processes consultation text data (appointment_reason)
# from both the merged DSC consultation dataset and Trello data.
# It tokenizes the text into single words and bi-grams, removes custom stop words,
# and saves the combined tokens for later use in an R Markdown report.
# ================================================

# Load necessary libraries
library(dplyr)
library(tidytext)
library(stringr)
library(readr)

# --------------------------------
# Load Datasets
# --------------------------------
# Load the cleaned and merged consultation data
dsc_consult <- readRDS("data/dsc_consult_merged.rds")

# Load the Trello data (if needed separately)
trello_data <- read_csv("data/ucla-datasquad-projects-trello.csv")

# --------------------------------
# Define Custom Stop Words
# --------------------------------
custom_stop_words <- data.frame(word = c("ucla"), stringsAsFactors = FALSE)
all_stop_words <- bind_rows(stop_words, custom_stop_words) %>%
  filter(word != "r")  # remove "r" if present

# --------------------------------
# Preprocess and Tokenize DSC Consultation Data
# --------------------------------
dsc_consult <- dsc_consult %>%
  filter(!is.na(appointment_reason)) %>%
  mutate(appointment_reason = str_replace_all(appointment_reason, "\\|", " "),
         appointment_reason = str_replace_all(appointment_reason, "[^a-zA-Z\\s]", " "),
         appointment_reason = tolower(appointment_reason))

# Tokenize into single words
single_words <- dsc_consult %>%
  mutate(document_id = as.character(row_number())) %>%
  unnest_tokens(word, appointment_reason) %>%
  filter(!word %in% all_stop_words$word)

# Tokenize into bi-grams
bi_grams <- dsc_consult %>%
  mutate(document_id = as.character(row_number())) %>%
  unnest_tokens(bigram, appointment_reason, token = "ngrams", n = 2) %>%
  separate(bigram, into = c("word1", "word2"), sep = " ") %>%
  filter(!word1 %in% all_stop_words$word, !word2 %in% all_stop_words$word) %>%
  unite(bigram, word1, word2, sep = " ") %>%
  filter(!is.na(bigram))

# Combine single words and bi-grams for dsc_consult
combined_tokens_consult <- bind_rows(
  single_words %>% mutate(bigram = word) %>% select(document_id, bigram),
  bi_grams
)

# --------------------------------
# Preprocess and Tokenize Trello Data
# --------------------------------
trello_data <- trello_data %>%
  filter(!is.na(appointment_reason)) %>%
  mutate(appointment_reason = str_replace_all(appointment_reason, "\\|", " "),
         appointment_reason = str_replace_all(appointment_reason, "[^a-zA-Z\\s]", " "),
         appointment_reason = tolower(appointment_reason))

# Tokenize into single words
single_words_trello <- trello_data %>%
  mutate(document_id = as.character(row_number())) %>%
  unnest_tokens(word, appointment_reason) %>%
  filter(!word %in% all_stop_words$word)

# Tokenize into bi-grams
bi_grams_trello <- trello_data %>%
  mutate(document_id = as.character(row_number())) %>%
  unnest_tokens(bigram, appointment_reason, token = "ngrams", n = 2) %>%
  separate(bigram, into = c("word1", "word2"), sep = " ") %>%
  filter(!word1 %in% all_stop_words$word, !word2 %in% all_stop_words$word) %>%
  unite(bigram, word1, word2, sep = " ") %>%
  filter(!is.na(bigram))

# Combine single words and bi-grams for trello_data
combined_tokens_trello <- bind_rows(
  single_words_trello %>% mutate(bigram = word) %>% select(document_id, bigram),
  bi_grams_trello
)

# --------------------------------
# Combine All Tokens and Save
# --------------------------------
combined_tokens <- bind_rows(combined_tokens_consult, combined_tokens_trello)

# Save the combined tokens for use in the R Markdown report
saveRDS(combined_tokens, "data/combined_tokens.rds")
saveRDS(combined_tokens, "data/trello_combined_tokens.rds")