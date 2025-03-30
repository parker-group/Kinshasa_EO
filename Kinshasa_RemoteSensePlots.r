## make some temporal plots of the values

library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)

# Load and prepare the data
csv_path <- "G:/Research/Kinshasa_EarthObserve/RemoteSense/KinshasaZonalStats_All.csv"
df <- read.csv(csv_path)



###start with MODIS derived LSTs
mlst_cols <- grep("^MLST", names(df), value = TRUE)
df[mlst_cols] <- lapply(df[mlst_cols], as.numeric)

df_mlst <- df %>%
  select(AS_, ZS, all_of(mlst_cols)) %>%
  pivot_longer(
    cols = starts_with("MLST"),
    names_to = "VariableMonth",
    values_to = "Temp_C"
  ) %>%
  mutate(
    Date = str_extract(VariableMonth, "[0-9]{6}"),
    Date = as.Date(paste0(Date, "01"), format = "%Y%m%d")
  )

# Filter highlight groups
highlight_orange <- df_mlst %>% filter(ZS %in% c("Binza-Meteo", "Binza Ozone")) %>% mutate(Group = "Binza")
highlight_green  <- df_mlst %>% filter(ZS == "Maluku 1") %>% mutate(Group = "Maluku")

# Combine for legend mapping
highlight_combined <- bind_rows(highlight_orange, highlight_green)

# Plot
p <- ggplot() +
  geom_line(data = df_mlst, aes(x = Date, y = Temp_C, group = AS_), color = "grey80", alpha = 0.6) +
  geom_line(data = highlight_combined, aes(x = Date, y = Temp_C, group = AS_, color = Group), size = 1) +
  scale_color_manual(values = c("Binza" = "darkorange", "Maluku" = "forestgreen")) +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
  labs(
    title = "MODIS derived land surface temp.",
    x = "Date", y = "Temperature (°C)",
    color = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )

# Now save it
ggsave("G:/Research/Kinshasa_EarthObserve/RemoteSense/MODIS_LST_TemporalPlot.png",
       p, width = 12, height = 5.5, dpi = 300)


#########################################################
##Same for ERA5-derived precipitation and temp
#########################################################
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(patchwork)  # <- NEW

# Load CSV once
csv_path <- "G:/Research/Kinshasa_EarthObserve/RemoteSense/KinshasaZonalStats_All.csv"
df <- read.csv(csv_path)

### --- PRECIPITATION --- ###
prcp_cols <- grep("^Prcp", names(df), value = TRUE)
df[prcp_cols] <- lapply(df[prcp_cols], as.numeric)

df_prcp <- df %>%
  select(AS_, ZS, all_of(prcp_cols)) %>%
  pivot_longer(
    cols = starts_with("Prcp"),
    names_to = "VariableMonth",
    values_to = "Prcp_mm"
  ) %>%
  mutate(
    Date = str_extract(VariableMonth, "[0-9]{6}"),
    Date = as.Date(paste0(Date, "01"), format = "%Y%m%d")
  )

highlight_orange_prcp <- df_prcp %>% filter(ZS %in% c("Binza-Meteo", "Binza Ozone")) %>% mutate(Group = "Binza")
highlight_green_prcp  <- df_prcp %>% filter(ZS == "Maluku 1") %>% mutate(Group = "Maluku")
highlight_combined_prcp <- bind_rows(highlight_orange_prcp, highlight_green_prcp)

p1 <- ggplot() +
  geom_line(data = df_prcp, aes(x = Date, y = Prcp_mm, group = AS_), color = "grey80", alpha = 0.6) +
  geom_line(data = highlight_combined_prcp, aes(x = Date, y = Prcp_mm, group = AS_, color = Group), size = 1) +
  scale_color_manual(values = c("Binza" = "darkorange", "Maluku" = "forestgreen")) +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
  labs(
    title = "ERA5 Precipitation",
    x = NULL, y = "Precipitation (mm/month)",
    color = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),
    axis.title.x = element_blank(),
    legend.position = "bottom"
  )

### --- TEMPERATURE --- ###
temp_cols <- grep("^Temp", names(df), value = TRUE)
df[temp_cols] <- lapply(df[temp_cols], as.numeric)

df_temp <- df %>%
  select(AS_, ZS, all_of(temp_cols)) %>%
  pivot_longer(
    cols = starts_with("Temp"),
    names_to = "VariableMonth",
    values_to = "Temp_C"
  ) %>%
  mutate(
    Date = str_extract(VariableMonth, "[0-9]{6}"),
    Date = as.Date(paste0(Date, "01"), format = "%Y%m%d")
  )

highlight_orange_temp <- df_temp %>% filter(ZS %in% c("Binza-Meteo", "Binza Ozone")) %>% mutate(Group = "Binza")
highlight_green_temp  <- df_temp %>% filter(ZS == "Maluku 1") %>% mutate(Group = "Maluku")
highlight_combined_temp <- bind_rows(highlight_orange_temp, highlight_green_temp)

p2 <- ggplot() +
  geom_line(data = df_temp, aes(x = Date, y = Temp_C, group = AS_), color = "grey80", alpha = 0.6) +
  geom_line(data = highlight_combined_temp, aes(x = Date, y = Temp_C, group = AS_, color = Group), size = 1) +
  scale_color_manual(values = c("Binza" = "darkorange", "Maluku" = "forestgreen")) +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
  labs(
    title = "ERA5 Temperature",
    x = "Date", y = "Temperature (°C)",
    color = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )

### --- COMBINE PLOTS --- ###
(p1 / p2) + plot_layout(guides = "collect") & theme(legend.position = "bottom")

#ggsave("G:/Research/Kinshasa_EarthObserve/RemoteSense/ERA5_ClimateStack.png",
       (p1 / p2) + plot_layout(guides = "collect") & theme(legend.position = "bottom"),
       width = 12, height = 6.75, dpi = 300)

#########################################################
##Same for MODIS derived vegetation and surface water 
#########################################################
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(patchwork)

# Load CSV
csv_path <- "G:/Research/Kinshasa_EarthObserve/RemoteSense/KinshasaZonalStats_All.csv"
df <- read.csv(csv_path)

### Helper function to generate one plot ###
make_panel_plot <- function(df, prefix, y_label, title) {
  cols <- grep(paste0("^", prefix), names(df), value = TRUE)
  df[cols] <- lapply(df[cols], as.numeric)
  
  df_long <- df %>%
    select(AS_, ZS, all_of(cols)) %>%
    pivot_longer(cols = all_of(cols), names_to = "VariableMonth", values_to = "Value") %>%
    mutate(
      Date = str_extract(VariableMonth, "[0-9]{6}"),
      Date = as.Date(paste0(Date, "01"), format = "%Y%m%d")
    )
  
  # Highlight groups
  highlight_orange <- df_long %>% filter(ZS %in% c("Binza-Meteo", "Binza Ozone")) %>% mutate(Group = "Binza")
  highlight_green  <- df_long %>% filter(ZS == "Maluku 1") %>% mutate(Group = "Maluku")
  highlight_combined <- bind_rows(highlight_orange, highlight_green)
  
  # Return plot
  ggplot() +
    geom_line(data = df_long, aes(x = Date, y = Value, group = AS_), color = "grey80", alpha = 0.6) +
    geom_line(data = highlight_combined, aes(x = Date, y = Value, group = AS_, color = Group), size = 1) +
    scale_color_manual(values = c("Binza" = "darkorange", "Maluku" = "forestgreen")) +
    scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
    labs(
      title = title,
      x = NULL,
      y = y_label,
      color = NULL
    ) +
    theme_minimal() +
    theme(
      axis.text.x = element_blank(),
      axis.title.x = element_blank(),
      legend.position = "none"
    )
}

### Create the three plots ###
p_ndvi <- make_panel_plot(df, "NDVI", "NDVI", "MODIS NDVI (normalized vegetation index)")
p_evi  <- make_panel_plot(df, "EVI_", "EVI", "MODIS EVI (enhanced vegetation index_")
p_ndwi <- make_panel_plot(df, "NDWI", "NDWI", "MODIS NDWI  (surface moisture/water)")

# Fix x-axis and legend only for the bottom panel
p_ndwi <- p_ndwi +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  ) +
  labs(x = "Date")

### Combine vertically ###
combined <- (p_ndvi / p_evi / p_ndwi) + plot_layout(guides = "collect")

#ggsave("G:/Research/Kinshasa_EarthObserve/RemoteSense/MODIS_VegIndicesStack.png",
       combined, width = 12, height = 10, dpi = 300)