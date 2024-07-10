# Sports Shoes Brand Data Analysis

This repository contains an R script for analyzing the social media and web presence of various sports shoe brands. The analysis includes data manipulation, cleaning, and visualization using `tidyverse` and `ggplot2`.

## Prerequisites

Ensure you have the following packages installed:

- `tidyverse`
- `ggplot2`

You can install them using the following R code:

```R
required_packages <- c("tidyverse", "ggplot2")

install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}

sapply(required_packages, install_if_missing)
```

## Data

The data used in this analysis includes three CSV files:

1. `brands.csv` - Contains information about various sports shoe brands.
2. `similarweb.csv` - Contains web traffic data for the brands.
3. `tiktok.csv` - Contains TikTok data related to the brands.

## Code Overview

1. **Load Libraries:**
    ```R
    library(tidyverse)
    library(ggplot2)
    ```

2. **Read CSV Files:**
    ```R
    df_brands <- read_csv("path/to/brands.csv")
    df_similarweb <- read_csv("path/to/similarweb.csv")
    df_tiktok <- read_csv("path/to/tiktok.csv")
    ```

3. **Data Cleaning and Preparation:**
    - Dropping unwanted columns from `df_brands`.
    - Standardizing brand names in `df_tiktok`.
    - Converting string representations of numbers (e.g., "1.2K", "3M") to integers.
    - Cleaning and transforming market capitalization values.

4. **Data Transformation:**
    - Grouping and summarizing TikTok data by brand.
    - Standardizing total visits in `df_similarweb`.
    - Merging all data frames into a single data frame.

5. **Analysis and Visualization:**
    - Defining columns for plotting various metrics such as followers, gender, and age demographics.
    - Creating visualizations using `ggplot2`.

## Output

The script generates various plots and summaries that provide insights into the social media and web presence of different sports shoe brands.

## Contributing

Contributions are welcome! Please fork the repository and create a pull request with your changes.
