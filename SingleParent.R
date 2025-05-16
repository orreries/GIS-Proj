library(tidyverse)
library(tidycensus)
library(dplyr)
library(cluster)
library(factoextra)
library(ggplot2)
library(ggcorrplot)
library(corrplot)
library(patchwork)
library(tibble)

#call data using Census API
census_api_key("7dee506a92455ee99e660915f549f182dead056b", install = TRUE, overwrite = TRUE)

edu_data <- get_acs(
  geography = "county",
  variables = c(bach_deg = "S1501_C02_015E",
                single_mom = "B11003_016E",
                total_fam_kids = "B11003_001E",
                single_dad = "B11003_010E"),
  year = 2023,
  survey = "acs5",
  output = "wide"
)

#delete columns/clean data
ls(edu_data)
View(edu_data)
data <- edu_data %>% select(c(GEOID,
                              NAME,
                          bach_deg,
                          single_mom,
                          total_fam_kids,
                          single_dad))
data <- na.omit(data)
View(data)

head(data)

#make percent variables for single parent households
data$mom_percent <- (edu_data$single_mom / data$total_fam_kids) * 100
data$bach_degree <- data$bach_deg 
data$dad_percent <- (edu_data$single_dad / data$total_fam_kids) * 100
data$single_parents <- ((edu_data$single_mom + edu_data$single_dad)/(data$total_fam_kids)) * 100

ls(data)

View(data)

#single parent variable metrics
mean(data$single_parents)
median(data$single_parents)
mean(dad_percent)
mean(single_mom)

#ggplot vizualization of regression models
#single parents total
p_SPH <- ggplot(data.frame(single_parents, bach_degree), aes(x = single_parents, y = bach_degree)) +
  geom_point(color = "#C54BF0", alpha = 0.34) +
  geom_smooth(method = "lm", color = "#ECE96A", se = TRUE, linetype = "dashed") +
  scale_x_continuous(limits = c(0, 30), name = "Single Parent Percent (County Level)") +
  scale_y_continuous(limits = c(0, 80), name = "Bachelor's Degree Attainment (%)") +
  labs(
    title = "Single Parents and Degree Attainment",
    x = "Percent of Single Parent Households per County",
    y = "Bachelor's Degree Attainment (%)") +
  theme(
    panel.background = element_rect(fill = "#262833", color = NA),
    plot.background = element_rect(fill = "#262633", color = NA), 
    panel.grid.major = element_line(color = "#3A3C47"),  # muted bluish-gray gridlines
    panel.grid.minor = element_line(color = "#3A3C47"),
    axis.text = element_text(color = "white"),
    axis.title = element_text(color = "white"),
    plot.title = element_text(color = "white", face = "bold"))

p_SPH

#single parents linear regression
#correlation (using Spearman)
cor(single_parents, bach_degree, method = "spearman")
cor.test(single_parents, bach_degree, method = "spearman")

#run a regression
#linear regression would be best 
#since im using a variable for bachelors attainment in percents
lm(bach_degree ~ single_parents)
lin_SP <- lm(bach_degree ~ single_parents)

#sum of squared residuals
erres <- residuals(lin_SP)
SSR <- sum(erres^2)
print(SSR)

#summary
summary(lin_SP)

############################################################################

#single mothers
p_mom <- ggplot(data.frame(mom_percent, bach_degree), aes(x = mom_percent, y = bach_degree)) +
  geom_point(color = "#AF8ECF", alpha = 0.25) +
  geom_smooth(method = "lm", color = "#ECE96A", se = TRUE, linetype = "dashed") +
  labs(
    title = "Single Mothers and Degree Attainment",
    x = "Percent of Single Mother Households (County Level)",
    y = "Bachelor's Degree Attainment (%)"
  ) +
  theme(
    panel.background = element_rect(fill = "#262833", color = NA),
    plot.background = element_rect(fill = "#262633", color = NA), 
    panel.grid.major = element_line(color = "#3A3C47"),  # muted bluish-gray gridlines
    panel.grid.minor = element_line(color = "#3A3C47"),
    axis.text = element_text(color = "white"),
    axis.title = element_text(color = "white"),
    plot.title = element_text(color = "white", face = "bold"))

p_mom

#correlation (using Spearman)
cor(mom_percent, bach_degree, method = "spearman")
cor.test(mom_percent, bach_degree, method = "spearman")

#run a regression
#linear regression would be best 
#since im using a variable for bachelors attainment in percents
lm(bach_degree ~ mom_percent)
lin_singlemom <- lm(bach_degree ~ mom_percent)

#sum of squared residuals
erres <- residuals(lin_singlemom)
SSR <- sum(erres^2)
print(SSR)

#summary
summary(lin_singlemom)

#################################################################################

#single father

#ggplot visualization of single father regression model
p_dad <- ggplot(data.frame(dad_percent, bach_degree), 
                aes(x = dad_percent, y = bach_degree)) +
  geom_point(color = "#FF69B4", alpha = 0.30) +
  geom_smooth(method = "lm", color = "#ECE96A", se = TRUE, linetype = "dashed") +
  scale_x_continuous(limits = c(0, 17), name = "Single Father Percent (County Level)") +
  scale_y_continuous(name = "Bachelor's Degree Attainment (%)") +
  labs(
    title = "Single Fathers and Degree Attainment") +
  theme_minimal(base_size = 14) +
  theme(
    panel.background = element_rect(fill = "#262833", color = NA),
    plot.background = element_rect(fill = "#262633", color = NA), 
    panel.grid.major = element_line(color = "#3A3C47"),  # muted bluish-gray gridlines
    panel.grid.minor = element_line(color = "#3A3C47"),
    axis.text = element_text(color = "white"),
    axis.title = element_text(color = "white"),
    plot.title = element_text(color = "white", face = "bold"))

p_dad

#correlation (using Spearman)
cor(dad_percent, bach_degree, method = "spearman")
cor.test(dad_percent, bach_degree, method = "spearman")

#comparison plot between single mothers and fathers
p_mom + p_dad

#run a regression
#linear regression would be best 
#since im using a variable for bachelors attainment in percents
lm(bach_degree ~ dad_percent)
lin_singledad <- lm(bach_degree ~ dad_percent)

#sum of squared residuals
erres2 <- residuals(lin_singledad)
SSR2 <- sum(erres2^2)
print(SSR2)

#summary
summary(lin_singledad)

######################################################################

#multiple linear regression to see how each variable differs
#combine predictors
model_data <- data.frame(
  bach_degree,
  mom_percent,
  dad_percent
)

#check correlation matrix
cor(model_data)

#VIF
library(car)
full_model <- lm(bach_degree ~ mom_percent + dad_percent, data = model_data)
vif(full_model)
summary(full_model)

census_api_key("7dee506a92455ee99e660915f549f182dead056b", install = TRUE, overwrite = TRUE)

#define a vector with variables
variables <- c( PovertyRate  = "S1701_C03_046E",
                Bachpct = "S1501_C02_012E",
                Median_Income = "S1901_C01_012E",
                MedianAge = "S0101_C01_032E",
                UnemploymentRate = "S2301_C04_001E"
)

#pulling my variables
data1 <- get_acs(geography = "county",
                 variables = variables,
                 output = "wide",
                 year = 2023)

#delete columns/clean data
ls(data1)
data1 <- data1 %>% dplyr::select(mom_percent,
                                 dad_percent,
                                 single_parents,
                                 PovertyRate,
                                 Median_Income,
                                 MedianAge,
                                 UnemploymentRate)
data <- na.omit(data)
View(data1)

#create variables
Median_Income <- data1$Median_Income
PovertyRate <- data1$PovertyRate
UnemploymentRate <- data1$UnemploymentRate

#Combined multilinear regression of both plus newly added variables 
#to see their effects on Bachelor degree attainment
multi.df <- data.frame(
  bach_degree,
  mom_percent,
  dad_percent,
  PovertyRate,
  Median_Income,
  UnemploymentRate)

#correlation
cor(multi.df)

multi_model <- lm(bach_degree ~ mom_percent + dad_percent + PovertyRate + Median_Income + UnemploymentRate, data = data)

summary(multi_model)

#corrplot
#model data
cor_matrix <- cor(multi.df, use = "complete.obs")
corrplot(cor_matrix)

#better corrplot (using ggcorrplot)
ggcorrplot(cor_matrix,
           hc.order = TRUE,
           type = "lower",
           lab = TRUE,
           colors = c("red", "white", "#008"),
           title = "Correlation Matrix of Variables")

#check for multicollinearity
vif(multi_model)

#stepwise for multi model
#load MASS for stepAIC
library(MASS)

#fit a full model
full_model_controls <- lm(bach_degree ~ mom_percent + dad_percent + PovertyRate + Median_Income + UnemploymentRate, data = multi.df)

#stepwise model using both directions (forward + backward)
stepwise_model <- stepAIC(full_model_controls, direction = "both", trace = TRUE)

#summary of stepwise model
summary(stepwise_model)

#check VIFs for final stepwise model
vif(stepwise_model)

##########################################################################
library(tibble)
library(broom)
library(car)

# Extract tidy summaries from models
model_SP <- tidy(lin_SP)
model_mom <- tidy(lin_singlemom)
model_dad <- tidy(lin_singledad)
model_full <- tidy(full_model)
model_multi <- tidy(multi_model)

# VIFs for multivariate models
vif_full <- vif(full_model)
vif_multi <- vif(multi_model)

# Combine into a tibble
all_models_summary <- tibble(
  Model = c(
    "Mother",
    "Father",
    "Comparison",
    "Controls"
  ),
  Intercept = c(27.90253, 27.28819, 30.35562, -11.10),
  `Mom Coef.` = c(model_mom$estimate[2], NA, model_full$estimate[2], model_multi$estimate[2]),
  `Mom p-value` = c(model_mom$p.value[2], NA, model_full$p.value[2], model_multi$p.value[2]),
  `Mom VIF` = c(NA, NA, vif_full["mom_percent"], vif_multi["mom_percent"]),
  
  `Dad Coef.` = c(NA, model_dad$estimate[2], model_full$estimate[3], model_multi$estimate[3]),
  `Dad p-value` = c(NA, model_dad$p.value[2], model_full$p.value[3], model_multi$p.value[3]),
  `Dad VIF` = c(NA, NA, vif_full["dad_percent"], vif_multi["dad_percent"]),
  
  `R-squared` = c(0.02731, 0.02731, 0.04908, 0.4848)
)

print(all_models_summary)

##################################################################################
#for GIS
# Purple-scale plot
p1 <- ggplot(data, aes(x = mom_percent, y = bach_degree)) +
  geom_point(color = "#FF69B4", size = 2, alpha = 0.7) +  # Medium plum-purple
  geom_smooth(method = "lm", color = "#6A1B9A", se = FALSE, linewidth = 1.2) +
  labs(title = "Single Mothers and Degree Attainment",
       x = "Single Mother Household Rate (%)",
       y = "Bachelor’s Degree Attainment (%)") +
  theme_minimal(base_size = 14) +
  theme(plot.background = element_rect(fill = "white", color = NA))

p1

# Blue-scale plot
p2 <- ggplot(data, aes(x = dad_percent, y = bach_degree)) +
  geom_point(color = "#3182BD", size = 2, alpha = 0.7) +  # Medium blue
  geom_smooth(method = "lm", color = "#08469C", se = FALSE, linewidth = 1.2) +
  labs(title = "Single Fathers and Degree Attainment",
       x = "Single Father Household Rate (%)",
       y = "Bachelor’s Degree Attainment (%)") +
  theme_minimal(base_size = 14) +
  theme(plot.background = element_rect(fill = "white", color = NA))

p2

p1 + p2