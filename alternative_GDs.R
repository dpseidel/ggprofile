# Profile using the pdf, RStudio GD, and Cairo::CairoPNG for comparison

# pdf GD
dev_info <- paste(Sys.info()[1], getOption("bitmapType"), Sys.Date(), sep = "_")
pdf(paste0("test_plots/", dev_info, ".pdf"))
base <- system.time(plot(diamonds$carat, diamonds$price))
timing <- lapply(plot_list, tidy_benchplot)
dev.off()

pdf <- timing %>%
  bind_rows() %>%
  mutate(plot_type = rep(names(timing), each = 5)) %>%
  add_row(
    step = "TOTAL",
    user.self = baseRGD[1],
    sys.self = baseRGD[2],
    elapsed = baseRGD[3],
    plot_type = "BaseR", .before = 1
  )

write_csv(pdf, paste0("results/ggProfile_pdf_", dev_info, ".csv"))


# RStudio GD profiling
# Rstudio GD lags and obscures timings.
library(tidyverse)
# plots from ggprofile.R

dev_info <- paste(Sys.info()[1], Sys.Date(), sep = "_")
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

write_csv(rgd, paste0("results/ggProfile_rgd_", dev_info, ".csv"))


# Cairo::CairoPNG() timings
library(Cairo)

dev_info <- paste(Sys.info()[1], "cairoPNG", Sys.Date(), sep = "_")
dir.create(paste0("test_plots/", dev_info))
CairoPNG(paste0("test_plots/", dev_info, "/plot%d.png"))
timing_cairo <- purrr::map(plots, tidy_benchplot)
base <- system.time(plot(diamonds$carat, diamonds$price))
dev.off()

# format as table
cairopng <- timing_cairo %>%
  bind_rows() %>%
  mutate(plot_type = rep(names(timing_cairo), each = 5)) %>%
  add_row(
    step = "TOTAL",
    user.self = base[1],
    sys.self = base[2],
    elapsed = base[3],
    plot_type = "BaseR", .before = 1
  )

write_csv(cairopng, paste0("results/ggProfile_png_", dev_info, ".csv"))
