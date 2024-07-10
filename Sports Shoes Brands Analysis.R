# Install and load packages
required_packages <- c("tidyverse", "ggplot2")

install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}

# Install and load the packages
sapply(required_packages, install_if_missing)


# Load necessary libraries
library(tidyverse)
library(ggplot2)

# Read the CSV files
df_brands <- read_csv("C:/Users/Shakir Ullah Shakir/Downloads/archive (1)/brands.csv")
df_similarweb <- read_csv("C:/Users/Shakir Ullah Shakir/Downloads/archive (1)/similarweb.csv")
df_tiktok <- read_csv("C:/Users/Shakir Ullah Shakir/Downloads/archive (1)/tiktok.csv")

# Define unique names, prefixes, and suffixes
unique_names <- c("wikipedia", "wikipedia_languages_num", "facebook", "twitter", "indeed", 
                  "mozcom_domain_authority", "mozcom_linking_root_domains", "mozcom_ranking_keywords", 
                  "site", "instagram", "youtube", "tiktok", "snapchat", "pinterest", "linkedin", 
                  "site_social_links", "corewebvitals_mobile", "corewebvitals_desktop")
prefixes <- c("corewebvitals_", "pagespeedweb_", "indeed_", "zippia_")
suffixes <- c("_verified", "_following", "_revenue", "revenue")

# Drop unwanted columns
columns_to_drop <- df_brands %>% 
  select(contains(prefixes) | ends_with(suffixes) | all_of(unique_names)) %>% 
  colnames()

df_brands <- df_brands %>% select(-all_of(columns_to_drop))

# Check data types
str(df_brands)

# Unique brand names in df_brands
brands_brandsNumber <- df_brands %>% select(name) %>% distinct() %>% nrow()
brands_brandsName <- df_brands %>% select(name) %>% distinct() %>% pull()
print(paste("brands_table - Number of brands:", brands_brandsNumber, "/ Names:", brands_brandsName))

# Select specific columns in df_similarweb
df_similarweb <- df_similarweb %>% 
  select(name, total_visits, bounce_rate, pages_per_visit, avg_visit_duration, 
         female, male, age_18_24, age_25_34, age_35_44, age_45_54, age_55_64, age_65_plus)

# Check data types
str(df_similarweb)

# Unique brand names in df_similarweb
similarweb_brandsNumber <- df_similarweb %>% select(name) %>% distinct() %>% nrow()
similarweb_brandsName <- df_similarweb %>% select(name) %>% distinct() %>% pull()
print(paste("similarweb_table - Number of brands:", similarweb_brandsNumber, ", Names:", similarweb_brandsName))

# Standardize brand names in df_tiktok
df_tiktok <- df_tiktok %>% 
  mutate(name = case_when(
    name == "adidas" ~ "Adidas",
    name == "asics" ~ "ASICS",
    name == "columbia" ~ "Columbia",
    name == "newbalance" ~ "New Balance",
    name == "nike" ~ "Nike",
    name == "puma" ~ "Puma",
    name == "skechers" ~ "Skechers",
    name == "underarmour" ~ "Under Armour",
    TRUE ~ name
  )) %>% 
  select(-description, -img_alt, -video_link, -warn_info)

# Check data types
str(df_tiktok)

# Function to convert string to integer
convert_string_to_int <- function(val) {
  val <- gsub(" ", "", val)
  if (grepl("k", val, ignore.case = TRUE)) {
    return(as.integer(as.numeric(sub("k", "", val, ignore.case = TRUE)) * 1e3))
  } else if (grepl("m", val, ignore.case = TRUE)) {
    return(as.integer(as.numeric(sub("m", "", val, ignore.case = TRUE)) * 1e6))
  } else if (grepl("b", val, ignore.case = TRUE)) {
    return(as.integer(as.numeric(sub("b", "", val, ignore.case = TRUE)) * 1e9))
  } else {
    return(as.integer(as.numeric(val)))
  }
}

# Apply conversion function to views in df_tiktok
df_tiktok <- df_tiktok %>% 
  mutate(views = sapply(views, convert_string_to_int))

# Group by name and sum views
df_tiktok <- df_tiktok %>% 
  group_by(name) %>% 
  summarise(tiktok_views = sum(views, na.rm = TRUE)) %>% 
  ungroup()

# Unique brand names in df_tiktok
tiktok_brandsNumber <- df_tiktok %>% select(name) %>% distinct() %>% nrow()
tiktok_brandsName <- df_tiktok %>% select(name) %>% distinct() %>% pull()
print(paste("tiktok_table - Number of brands:", tiktok_brandsNumber, "/ Names:", tiktok_brandsName))

# Apply conversion function to total_visits in df_similarweb
df_similarweb <- df_similarweb %>% 
  mutate(total_visits = sapply(total_visits, convert_string_to_int))

# Apply conversion function to social media columns in df_brands
social_media_cols <- c("facebook_likes", "facebook_followers", "instagram_followers", 
                       "youtube_subscribers", "tiktok_followers", "tiktok_likes", "pinterest_followers")
df_brands <- df_brands %>% 
  mutate(across(all_of(social_media_cols), ~ sapply(., convert_string_to_int)))

# Function to clean market cap values
clean_amount <- function(val) {
  val <- gsub("\\$", "", val)
  val <- gsub(",", "", val)
  if (grepl("billion", val, ignore.case = TRUE)) {
    return(as.numeric(sub(" billion", "", val, ignore.case = TRUE)) * 1e9)
  } else if (grepl("million", val, ignore.case = TRUE)) {
    return(as.numeric(sub(" million", "", val, ignore.case = TRUE)) * 1e6)
  } else if (grepl("thousand", val, ignore.case = TRUE)) {
    return(as.numeric(sub(" thousand", "", val, ignore.case = TRUE)) * 1e3)
  } else {
    return(as.numeric(val))
  }
}

# Apply clean_amount function to market_cap in df_brands
df_brands <- df_brands %>% 
  mutate(market_cap = sapply(market_cap, clean_amount))

# Merge dataframes
df <- df_brands %>% 
  full_join(df_similarweb, by = "name") %>% 
  full_join(df_tiktok, by = "name")

# Define columns for plotting
followers <- c("twitter_followers", "facebook_followers", "instagram_followers", 
               "youtube_subscribers", "tiktok_followers", "pinterest_followers")
gender <- c("male", "female")
ages <- c("age_18_24", "age_25_34", "age_35_44", "age_45_54", "age_55_64", "age_65_plus")
views <- c("youtube_views", "tiktok_views")

# Plot Followers
df %>% 
  select(name, all_of(followers)) %>% 
  pivot_longer(cols = -name, names_to = "social_media", values_to = "followers") %>% 
  ggplot(aes(x = name, y = followers, fill = social_media)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal() +
  labs(title = "Followers on each social media account", x = "Brand", y = "Followers") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Plot Views
df %>% 
  select(name, all_of(views)) %>% 
  pivot_longer(cols = -name, names_to = "social_media", values_to = "views") %>% 
  ggplot(aes(x = name, y = views, fill = social_media)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal() +
  labs(title = "Views on each social media account", x = "Brand", y = "Views") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Plot Ages
df %>% 
  select(name, all_of(ages)) %>% 
  pivot_longer(cols = -name, names_to = "age_group", values_to = "percentage") %>% 
  ggplot(aes(x = name, y = percentage, fill = age_group)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal() +
  labs(title = "Customer's ages", x = "Brand", y = "Percentage") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Plot Gender
df %>% 
  select(name, all_of(gender)) %>% 
  pivot_longer(cols = -name, names_to = "gender", values_to = "percentage") %>% 
  ggplot(aes(x = name, y = percentage, fill = gender)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal() +
  labs(title = "Gender's percent", x = "Brand", y = "Percentage") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Calculate total followers and total views
df <- df %>% 
  mutate(total_followers = rowSums(across(all_of(followers)), na.rm = TRUE),
         total_views = rowSums(across(all_of(views)), na.rm = TRUE))

# Calculate correlations
correlation_market_cap <- cor(df$market_cap, df$total_followers, use = "complete.obs")
correlation_visit <- cor(df$market_cap, df$total_visits, use = "complete.obs")
print(paste("market_cap:", correlation_market_cap))
print(paste("visit:", correlation_visit))
