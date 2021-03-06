# Code for profiling ggplot2
# June 13, 2018
# dpseidel

library(grid)
library(sf)
library(tidyverse) # loading ggplot2 ‘2.2.1.9000’

# Data
mcor <- cor(mtcars) %>%
  as.data.frame() %>%
  rownames_to_column("var1") %>%
  gather(var2, cor, -var1)

usa <- map_data("usa")
states <- map_data("state")

nc <- st_read(system.file("shape/nc.shp", package = "sf"))
nc_whole <- st_union(nc)


# Plot calls
plots <- exprs(
  lg_sctr = ggplot(diamonds, aes(carat, price)) +
    geom_point(),
  sm_sctr = ggplot(diamonds[1:1000, ], aes(carat, price)) +
    geom_point(),
  trans = ggplot(diamonds, aes(carat, price)) + geom_point() +
    scale_x_log10(),
  many_axis = ggplot(diamonds, aes(carat, price)) +
    geom_point() +
    scale_x_continuous(breaks = seq(0, 5, .25)),
  no_lgd = ggplot(diamonds, aes(carat, price, colour = cut)) +
    geom_point() +
    theme(legend.position = "none"),
  sm_lgd_d = ggplot(diamonds, aes(carat, price, colour = cut)) +
    geom_point(),
  lg_lgd_d = ggplot(diamonds, aes(carat, price, colour = clarity)) +
    geom_point(),
  lgd_c = ggplot(diamonds, aes(carat, price, colour = depth)) +
    geom_point(),
  fct_5 = ggplot(diamonds, aes(carat, price)) + geom_point() +
    facet_grid(. ~ cut),
  fct_35 = ggplot(diamonds, aes(carat, price)) + geom_point() +
    facet_grid(vars(color), vars(cut)),
  ht_map = ggplot(mcor, aes(var1, var2, fill = cor)) +
    geom_raster(),
  lyr2 = ggplot(diamonds, aes(carat, price)) +
    geom_point() +
    geom_smooth(aes(colour = "lm"), method = "lm", se = FALSE),
  lyr3 = ggplot(diamonds, aes(carat, price)) +
    geom_point() +
    geom_smooth(aes(colour = "loess"), method = "loess", se = FALSE) +
    geom_smooth(aes(colour = "lm"), method = "lm", se = FALSE),
  hist = ggplot(diamonds, aes(x = price, fill = cut)) +
    geom_histogram(binwidth = 1000),
  hist_dg = ggplot(diamonds, aes(x = price, fill = cut)) +
    geom_histogram(position = "dodge", binwidth = 1000),
  hist_mny_bns = ggplot(diamonds, aes(x = price, fill = cut)) +
    geom_histogram(binwidth = 100),
  maps_us = ggplot(data = usa) +
    geom_polygon(aes(x = long, y = lat, group = group)) +
    coord_fixed(1.3),
  maps_sts = ggplot(data = states) +
    geom_polygon(aes(x = long, y = lat, group = group)) +
    coord_fixed(1.3),
  sf_many = ggplot(data = nc_whole) + geom_sf(),
  sf_one = ggplot(data = nc) + geom_sf()
)


# adjust ggplot2::benchplot function to except expr
tidy_benchplot <- function(x) {
  gc()
  construct <- system.time(x <- rlang::eval_tidy(x))
  stopifnot(inherits(x, "ggplot"))

  build <- system.time(data <- ggplot_build(x))
  render <- system.time(grob <- ggplot_gtable(data))
  grid.newpage() # added for iteration, so we are not drawing on the same page
  draw <- system.time(grid.draw(grob))

  times <- rbind(construct, build, render, draw)[, 1:3]

  plyr::unrowname(data.frame(
    step = c("construct", "build", "render", "draw", "TOTAL"),
    rbind(times, colSums(times))
  ))
}

# Profile and Plot
#

png_profile <- function(plot_list = plots, driver = getOption("bitmapType")) {
  dev_info <- paste(Sys.info()[1], driver, Sys.Date(), sep = "_")
  dir.create(paste0("test_plots/", dev_info))

  png(paste0("test_plots/", dev_info, "/plot%d.png"), type = driver)
  base <- system.time(plot(diamonds$carat, diamonds$price))
  timing <- lapply(plot_list, tidy_benchplot)
  dev.off()

  table <- timing %>%
    bind_rows() %>%
    mutate(plot_type = rep(names(timing), each = 5)) %>%
    add_row(
      step = "TOTAL",
      user.self = base[1],
      sys.self = base[2],
      elapsed = base[3],
      plot_type = "BaseR", .before = 1
    )

  write_csv(table, paste0("results/ggProfile_png_", dev_info, ".csv"))
  return(table)
}

device_results <- purrr::map(c("quartz", "cairo", "Xlib"), ~ png_profile(plots, driver = .))

# on Windows
# png_profile(plots)
