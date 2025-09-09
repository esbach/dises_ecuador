# Set your folder path
folder <- "/Users/michaelesbach/Documents/Research/DISES/Website/DISES-Website/images/photos"

# List image files (adjust pattern as needed)
files <- list.files(folder, pattern = "\\.(jpg|jpeg|png)$", full.names = TRUE, ignore.case = TRUE)

# Total number of images
n <- length(files)

# Generate random numbers from 1 to n, then pad with zero
random_ids <- sprintf("dises%02d", sample(1:n))

# Create new file names with same extension
file_exts <- tools::file_ext(files)
new_names <- file.path(folder, paste0(random_ids, ".", file_exts))

# Rename files
file.rename(files, new_names)
