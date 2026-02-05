# Load necessary libraries
library(dplyr)
library(tidytext)
library(tm)
library(topicmodels)
library(reshape2)
library(readr)

# Load the cleaned and merged data
dsc_consult <- readRDS("data/dsc_consult_merged.rds")

# Verify the structure of the dataframe
print(colnames(dsc_consult))
print(head(dsc_consult))

# Check if the column 'appointment_reason' exists
if (!"appointment_reason" %in% colnames(dsc_consult)) {
  stop("The column 'appointment_reason' is not found in the dataframe.")
}

# Define custom stop words
custom_stop_words <- data.frame(word = c("ucla"), stringsAsFactors = FALSE)

# Combine with existing stop words from tidytext and remove "r"
all_stop_words <- bind_rows(stop_words, custom_stop_words) %>%
  filter(word != "r")

# Preprocess the text data
dsc_consult <- dsc_consult %>%
  filter(!is.na(appointment_reason)) %>%
  mutate(appointment_reason = str_replace_all(appointment_reason, "\\|", " "),
         appointment_reason = str_replace_all(appointment_reason, "[^a-zA-Z\\s]", " "),
         appointment_reason = tolower(appointment_reason))

# Tokenize the text data into single words and bi-grams while preserving the document identifier
single_words <- dsc_consult %>%
  mutate(document_id = as.character(row_number())) %>%  # Add a unique document identifier as character
  unnest_tokens(word, appointment_reason) %>%
  filter(!word %in% all_stop_words$word)

bi_grams <- dsc_consult %>%
  mutate(document_id = as.character(row_number())) %>%
  unnest_tokens(bigram, appointment_reason, token = "ngrams", n = 2) %>%
  separate(bigram, into = c("word1", "word2"), sep = " ") %>%
  filter(!word1 %in% all_stop_words$word, !word2 %in% all_stop_words$word) %>%
  unite(bigram, word1, word2, sep = " ") %>%
  filter(!is.na(bigram))

# Combine single words and bi-grams
combined_tokens <- bind_rows(
  single_words %>% mutate(bigram = word) %>% select(document_id, bigram),
  bi_grams
)

# Check the structure of combined_tokens
head(combined_tokens)

# Create a Document-Term Matrix
dtm_data <- combined_tokens %>%
  count(document_id, bigram) %>%
  filter(!is.na(bigram))

# Cast to Document-Term Matrix
dtm <- dtm_data %>%
  cast_dtm(document_id, bigram, n)

# Perform Latent Dirichlet Allocation (LDA)
lda_model <- LDA(dtm, k = 4, control = list(seed = 1234))

# Get the topics
topics <- tidy(lda_model, matrix = "beta")

# Get the top terms for each topic
top_terms <- topics %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

# Print the top terms for each topic
print(top_terms)

# Get the document-topic probabilities
document_topics <- tidy(lda_model, matrix = "gamma")

# Ensure document_topics has the right structure
print(head(document_topics))

# Identify the most probable topic for each document
document_topics <- document_topics %>%
  group_by(document) %>%
  slice_max(gamma, n = 1) %>%
  ungroup() %>%
  select(document, topic)

# Check the structure of document_topics
print(head(document_topics))

# Ensure the column names match before joining
dsc_consult <- dsc_consult %>%
  mutate(document_id = as.character(row_number()))  # Ensure document_id is present and as character in dsc_consult

# Check the structure of dsc_consult
print(head(dsc_consult))

# Join the topics with the original dataframe
dsc_consult <- dsc_consult %>%
  left_join(document_topics, by = c("document_id" = "document"))

# Check the structure after join
print(head(dsc_consult))

# Classify each document to the most probable topic
dsc_consult <- dsc_consult %>%
  mutate(topic = paste0("Topic ", topic))
