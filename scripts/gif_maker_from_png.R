library(magick)

# Settings 
patt = 'ss'               # Prefix of files for patter nmatching 
path.files = "~/Desktop/" # Path of files 
ext = '.png'
file.out = "dancing_queen1.gif"
# List all files with this prefix and ends in .png 
lf <- list.files(
  path = path.files,
  pattern = glob2rx(sprintf("%s*%s", patt, ext)),
  # Files in order 
  full.names = TRUE
) |> 
  sort()

# Fps allowed (however, 0.1 is ok...)
# (1:100)[which((100%%1:100) == 0)]

# Make the gif
animation <- lf |> 
  image_read() |>  # Reads each file path into a frame
  image_scale("128") |>  # Resize width to 128 pixels (height is auto-adjusted)
  image_join() |>  # Joins individual image frames into a multi-frame image object
  # image_animate(fps = 1, loop = 0) |> # Animates the frames (fps = 0.1, 1, 2, 5, 10,  frames per second, 0 for infinite loop)
  image_animate(delay = 100/8, loop = 0) |> # Animates the frames (fps = 0.1, 1, 2, 5, 10,  frames per second, 0 for infinite loop)
  image_write(file.path(path.files,
                        file.out)) # Writes the result to a 
 