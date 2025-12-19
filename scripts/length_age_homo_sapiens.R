# Calculate the length of human existence on earth 
# compared to the age of the earth 
# reported as a distance unit 

# devtools::install_github("https://github.com/petergandenberger/dashboard-builder")
# dashboardBuilder::run_app()

# Set the parameters 
age_earth <- 4.5e9 # was originally 4,000,000,000 years
measure_m <- 1 # in meter
age_homo_sapiens <- 2e5 # more or less 300,000 years

# If age earth = 1m, what is the length in m of the age of Homo sapiens?
# age_earth        => measure_m
# age_homo_sapiens => x

library(units)
length_m <- (measure_m * age_homo_sapiens) / age_earth
lm <- set_units(x = length_m, value = m)
units(lm) <- make_units(µm) # Transform to micrometer
lm
# 45 [µm] # Limit of average human vision to see with naked eye, size of dust particle
# 75 [µm]

# Compare that length to the 'Human parainfluenza viruses'
# https://en.wikipedia.org/wiki/Human_parainfluenza_viruses
floor(lm/set_units(x = 250, value = nm))
# About 300 viruses! 

# https://en.wikipedia.org/wiki/Hair%27s_breadth
# About 75 [µm] on average! 
# Notre histoire est de la largeur d'un poil! 