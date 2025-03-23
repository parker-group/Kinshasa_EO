#########################################
#### Kinshasa weather station data  #####
#########################################

#### generate a list of weather stations in Kinshasa area
library(rnoaa)
library(dplyr)

# Load ISD station metadata
stations <- isd_stations()

# Filter stations near Kinshasa (rough bounding box)
kinshasa_stations <- stations %>%
  filter(lat > -5 & lat < -4, 
         lon > 15 & lon < 16)

# View resulting stations
print(kinshasa_stations)


#####extract weather station data using station identifiers and dates
# Load required packages
library(rnoaa)
library(dplyr)
library(lubridate)
library(tidyr)  # for replace_na
library(ggplot2)
library(gridExtra)

# Set station identifiers for Kinshasa/N’djili
usaf <- "642100"
wban <- "99999"
years <- 2022:2023

# Force fresh download and load data for both years
isd_data_list <- list()
for (year in years) {
  isd_data_list[[as.character(year)]] <- isd(usaf = usaf, wban = wban, year = year, force = TRUE)
}

# Combine into one data frame
isd_raw <- bind_rows(isd_data_list)

# Convert date column to Date type
isd_raw <- isd_raw %>%
  mutate(date = as.Date(date, format = "%Y%m%d"))

# Create temperature dataset with QC flag
temp_data <- isd_raw %>%
  select(date, temperature, temperature_quality) %>%
  filter(!is.na(temperature), temperature != "9999", temperature != "+9999", temperature_quality == "1") %>%
  mutate(temperature = as.numeric(temperature) / 10) %>%
  group_by(date) %>%
  summarise(daily_temp = mean(temperature, na.rm = TRUE), .groups = "drop")

# Create precipitation dataset with NOAA QC flag only
precip_data <- isd_raw %>%
  select(date, AA1_depth, AA1_quality_code) %>%
  filter(!is.na(AA1_depth), AA1_depth != "9999", AA1_quality_code == "1") %>%
  mutate(AA1_depth = as.numeric(AA1_depth) / 10) %>%
  group_by(date) %>%
  summarise(daily_precip = sum(AA1_depth, na.rm = TRUE), .groups = "drop")

# Merge temperature and precipitation to preserve all dates
daily_weather <- full_join(temp_data, precip_data, by = "date") %>%
  arrange(date)

# Create monthly summary (missing precip = 0)
monthly_weather <- daily_weather %>%
  mutate(month = floor_date(date, unit = "month")) %>%
  group_by(month) %>%
  summarise(
    avg_temp = mean(daily_temp, na.rm = TRUE),
    total_precip = sum(replace_na(daily_precip, 0), na.rm = TRUE),
    .groups = "drop"
  )

# View output
print(monthly_weather, n=25)

# Plot Monthly Average Temperature (with y-axis limit set to 10 - 45°C)
temp_plot <- ggplot(monthly_weather, aes(x = month, y = avg_temp)) +
  geom_line(color = "red", size = 1) +
  geom_point(color = "darkred", size = 2) +
  labs(title = "Monthly Average Temperature (N’djili)", x = "Month", y = "Temperature (°C)") +
  scale_x_date(date_labels = "%b %Y", date_breaks = "2 months") +
  scale_y_continuous(limits = c(10, 30)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Plot Monthly Total Precipitation
precip_plot <- ggplot(monthly_weather, aes(x = month, y = total_precip)) +
  geom_bar(stat = "identity", fill = "blue", alpha = 0.7) +
  labs(title = "Total Monthly Precipitation (N’djili)", x = "Month", y = "Precipitation (mm)") +
  scale_x_date(date_labels = "%b %Y", date_breaks = "2 months") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Combine the plots vertically
grid.arrange(temp_plot, precip_plot, ncol = 1)

# Export daily and monthly weather data
write.csv(daily_weather, "G:/Research/Kinshasa_EarthObserve/daily_weather_Ndjili.csv", row.names = FALSE)
write.csv(monthly_weather, "G:/Research/Kinshasa_EarthObserve/monthly_weather_Ndjili.csv", row.names = FALSE)


#############################################
#### KINSHASA/BINZA Weather Station Data #####
#############################################

usaf_binza <- "642200"
wban_binza <- "99999"

isd_data_list_binza <- list()
for (year in years) {
  isd_data_list_binza[[as.character(year)]] <- isd(usaf = usaf_binza, wban = wban_binza, year = year, force = TRUE)
}
isd_raw_binza <- bind_rows(isd_data_list_binza) %>%
  mutate(date = as.Date(date, format = "%Y%m%d"))

temp_data_binza <- isd_raw_binza %>%
  select(date, temperature, temperature_quality) %>%
  filter(!is.na(temperature), temperature != "9999", temperature != "+9999", temperature_quality == "1") %>%
  mutate(temperature = as.numeric(temperature) / 10) %>%
  group_by(date) %>%
  summarise(daily_temp = mean(temperature, na.rm = TRUE), .groups = "drop")

precip_data_binza <- isd_raw_binza %>%
  select(date, AA1_depth, AA1_quality_code) %>%
  filter(!is.na(AA1_depth), AA1_depth != "9999", AA1_quality_code == "1") %>%
  mutate(AA1_depth = as.numeric(AA1_depth) / 10) %>%
  group_by(date) %>%
  summarise(daily_precip = sum(AA1_depth, na.rm = TRUE), .groups = "drop")

daily_weather_binza <- full_join(temp_data_binza, precip_data_binza, by = "date") %>%
  arrange(date)

# View output
#print(daily_weather_binza, n=50)

monthly_weather_binza <- daily_weather_binza %>%
  mutate(month = floor_date(date, unit = "month")) %>%
  group_by(month) %>%
  summarise(
    avg_temp = mean(daily_temp, na.rm = TRUE),
    total_precip = sum(replace_na(daily_precip, 0), na.rm = TRUE),
    .groups = "drop"
  )

# View output
print(monthly_weather_binza, n=25)

temp_plot_binza <- ggplot(monthly_weather_binza, aes(x = month, y = avg_temp)) +
  geom_line(color = "red", size = 1) +
  geom_point(color = "darkred", size = 2) +
  labs(title = "Monthly Average Temperature (Binza)", x = "Month", y = "Temperature (°C)") +
  scale_x_date(date_labels = "%b %Y", date_breaks = "2 months") +
  scale_y_continuous(limits = c(10, 30)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

precip_plot_binza <- ggplot(monthly_weather_binza, aes(x = month, y = total_precip)) +
  geom_bar(stat = "identity", fill = "blue", alpha = 0.7) +
  labs(title = "Total Monthly Precipitation (Binza)", x = "Month", y = "Precipitation (mm)") +
  scale_x_date(date_labels = "%b %Y", date_breaks = "2 months") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

grid.arrange(temp_plot_binza, precip_plot_binza, ncol = 1)

write.csv(daily_weather_binza, "G:/Research/Kinshasa_EarthObserve/daily_weather_binza.csv", row.names = FALSE)
write.csv(monthly_weather_binza, "G:/Research/Kinshasa_EarthObserve/monthly_weather_binza.csv", row.names = FALSE)


#############################################
#### MAYA MAYA Weather Station Data #########
#############################################

usaf_maya <- "644500"
wban_maya <- "99999"

isd_data_list_maya <- list()
for (year in years) {
  isd_data_list_maya[[as.character(year)]] <- isd(usaf = usaf_maya, wban = wban_maya, year = year, force = TRUE)
}
isd_raw_maya <- bind_rows(isd_data_list_maya) %>%
  mutate(date = as.Date(date, format = "%Y%m%d"))

temp_data_maya <- isd_raw_maya %>%
  select(date, temperature, temperature_quality) %>%
  filter(!is.na(temperature), temperature != "9999", temperature != "+9999", temperature_quality == "1") %>%
  mutate(temperature = as.numeric(temperature) / 10) %>%
  group_by(date) %>%
  summarise(daily_temp = mean(temperature, na.rm = TRUE), .groups = "drop")

precip_data_maya <- isd_raw_maya %>%
  select(date, AA1_depth, AA1_quality_code) %>%
  filter(!is.na(AA1_depth), AA1_depth != "9999", AA1_quality_code == "1") %>%
  mutate(AA1_depth = as.numeric(AA1_depth) / 10) %>%
  group_by(date) %>%
  summarise(daily_precip = sum(AA1_depth, na.rm = TRUE), .groups = "drop")

daily_weather_maya <- full_join(temp_data_maya, precip_data_maya, by = "date") %>%
  arrange(date)

monthly_weather_maya <- daily_weather_maya %>%
  mutate(month = floor_date(date, unit = "month")) %>%
  group_by(month) %>%
  summarise(
    avg_temp = mean(daily_temp, na.rm = TRUE),
    total_precip = sum(replace_na(daily_precip, 0), na.rm = TRUE),
    .groups = "drop"
  )

# View output
print(monthly_weather_maya, n=25)

temp_plot_maya <- ggplot(monthly_weather_maya, aes(x = month, y = avg_temp)) +
  geom_line(color = "red", size = 1) +
  geom_point(color = "darkred", size = 2) +
  labs(title = "Monthly Average Temperature – MAYA MAYA", x = "Month", y = "Temperature (°C)") +
  scale_x_date(date_labels = "%b %Y", date_breaks = "2 months") +
  scale_y_continuous(limits = c(10, 30)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

precip_plot_maya <- ggplot(monthly_weather_maya, aes(x = month, y = total_precip)) +
  geom_bar(stat = "identity", fill = "blue", alpha = 0.7) +
  labs(title = "Total Monthly Precipitation – MAYA MAYA", x = "Month", y = "Precipitation (mm)") +
  scale_x_date(date_labels = "%b %Y", date_breaks = "2 months") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

grid.arrange(temp_plot_maya, precip_plot_maya, ncol = 1)

write.csv(daily_weather_maya, "G:/Research/Kinshasa_EarthObserve/daily_weather_maya.csv", row.names = FALSE)
write.csv(monthly_weather_maya, "G:/Research/Kinshasa_EarthObserve/monthly_weather_maya.csv", row.names = FALSE)


#############################################
#### KINSHASA/N'DOLO Weather Station Data ####
#############################################

usaf_ndolo <- "642110"
wban_ndolo <- "99999"

isd_data_list_ndolo <- list()
for (year in years) {
  isd_data_list_ndolo[[as.character(year)]] <- isd(usaf = usaf_ndolo, wban = wban_ndolo, year = year, force = TRUE)
}
isd_raw_ndolo <- bind_rows(isd_data_list_ndolo) %>%
  mutate(date = as.Date(date, format = "%Y%m%d"))

temp_data_ndolo <- isd_raw_ndolo %>%
  select(date, temperature, temperature_quality) %>%
  filter(!is.na(temperature), temperature != "9999", temperature != "+9999", temperature_quality == "1") %>%
  mutate(temperature = as.numeric(temperature) / 10) %>%
  group_by(date) %>%
  summarise(daily_temp = mean(temperature, na.rm = TRUE), .groups = "drop")

precip_data_ndolo <- isd_raw_ndolo %>%
  select(date, AA1_depth, AA1_quality_code) %>%
  filter(!is.na(AA1_depth), AA1_depth != "9999", AA1_quality_code == "1") %>%
  mutate(AA1_depth = as.numeric(AA1_depth) / 10) %>%
  group_by(date) %>%
  summarise(daily_precip = sum(AA1_depth, na.rm = TRUE), .groups = "drop")

daily_weather_ndolo <- full_join(temp_data_ndolo, precip_data_ndolo, by = "date") %>%
  arrange(date)

monthly_weather_ndolo <- daily_weather_ndolo %>%
  mutate(month = floor_date(date, unit = "month")) %>%
  group_by(month) %>%
  summarise(
    avg_temp = mean(daily_temp, na.rm = TRUE),
    total_precip = sum(replace_na(daily_precip, 0), na.rm = TRUE),
    .groups = "drop"
  )

# View output
print(monthly_weather_ndolo, n=25)

temp_plot_ndolo <- ggplot(monthly_weather_ndolo, aes(x = month, y = avg_temp)) +
  geom_line(color = "red", size = 1) +
  geom_point(color = "darkred", size = 2) +
  labs(title = "Monthly Average Temperature (N'Dolo)", x = "Month", y = "Temperature (°C)") +
  scale_x_date(date_labels = "%b %Y", date_breaks = "2 months") +
  scale_y_continuous(limits = c(10, 30)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

precip_plot_ndolo <- ggplot(monthly_weather_ndolo, aes(x = month, y = total_precip)) +
  geom_bar(stat = "identity", fill = "blue", alpha = 0.7) +
  labs(title = "Total Monthly Precipitation (N'Dolo)", x = "Month", y = "Precipitation (mm)") +
  scale_x_date(date_labels = "%b %Y", date_breaks = "2 months") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

grid.arrange(temp_plot_ndolo, precip_plot_ndolo, ncol = 1)

write.csv(daily_weather_ndolo, "G:/Research/Kinshasa_EarthObserve/daily_weather_ndolo.csv", row.names = FALSE)
write.csv(monthly_weather_ndolo, "G:/Research/Kinshasa_EarthObserve/monthly_weather_ndolo.csv", row.names = FALSE)


############################################################
#### comparison plots between the weather stations
############################################################

# Combine all monthly temperature data with station labels
temp_compare <- bind_rows(
  monthly_weather %>% mutate(station = "Ndjili"),
  monthly_weather_binza %>% mutate(station = "Binza"),
  monthly_weather_maya %>% mutate(station = "Maya Maya"),
  monthly_weather_ndolo %>% mutate(station = "N'Dolo")
)

# Plot temperature comparison
ggplot(temp_compare, aes(x = month, y = avg_temp, color = station)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  labs(
    title = "Monthly Average Temperature – All Stations",
    x = "Month", y = "Temperature (°C)"
  ) +
  scale_x_date(date_labels = "%b %Y", date_breaks = "2 months") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))



# Combine all monthly precipitation data with station labels
precip_compare <- bind_rows(
  monthly_weather %>% mutate(station = "Ndjili"),
  monthly_weather_binza %>% mutate(station = "Binza"),
  monthly_weather_maya %>% mutate(station = "Maya Maya"),
  monthly_weather_ndolo %>% mutate(station = "N'Dolo")
)

# Plot precipitation comparison
ggplot(precip_compare, aes(x = month, y = total_precip, color = station)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  labs(
    title = "Monthly Total Precipitation – All Stations",
    x = "Month", y = "Precipitation (mm)"
  ) +
  scale_x_date(date_labels = "%b %Y", date_breaks = "2 months") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
