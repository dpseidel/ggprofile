# Profile using the RStudio GD for comparison
# Rstudio GD lags and obscures timings.
library(tidyverse)
# plots from ggprofile.R

timing_RStudioGD <- purrr::map(plots, tidy_benchplot)
baseRGD <- system.time(plot(diamonds$carat, diamonds$price))

# format as table
rgd <- timing_RStudioGD %>%
  bind_rows() %>%
  mutate(plot_type = rep(names(timing_RStudioGD), each = 5)) %>%
  add_row(
    step = "TOTAL",
    user.self = baseRGD[1],
    sys.self = baseRGD[2],
    elapsed = baseRGD[3],
    plot_type = "BaseR", .before = 1
  )

write_csv(rgd, paste0("results/ggProfile_", dev_info, "_RstudioGD.csv"))
