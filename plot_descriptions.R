# Description Table

descriptions <- tibble(
  `Plot Names` = c("BaseR", names(timing)),
  `Plot Description` = c(
    "BaseR - Scatterplot w/ 50k+ points",
    "Scatterplot w/ 50k+ points", "Scatterplot w/1K points",
    "Scatterplot w/ transformed scale",
    "Scatterplot w/ many axis lables",
    "No Legend",
    "Small discrete legend (5 levels)",
    "Larger discrete legend (8 levels)",
    "Continuous legend",
    "Facetting Scatterplot - 5 facets",
    "Facetting Scatterplot - 35 facets",
    "Heat map with labels",
    "2 layers - scatter + geom_smooth (lm)",
    "3 layers - scatter + geom_smooth (lm & loess)",
    "histogram, position = stack",
    "histogram, position = dodge",
    "histogram, many bins",
    "maps, geom_polygon, usa",
    "maps, geom_polygon, states",
    "geom_sf, 100 small polygons",
    "geom_sf, one large multi-polygon"
  )
)

write_csv(descriptions, "plot_descriptions.csv")
