library(magick)

bytes_to_mb <- function(bytes) bytes / 1024 / 1024

convert_jpg_adaptive <- function(
    file,
    output_dir,
    max_mb = 0.5,          # target ~0.5 MB
    start_quality = 85,    # start a bit lower than 95
    min_quality = 70,      # don't go below this unless you want stronger compression
    resize_step = 0.9,
    min_width = 1000
) {
  img <- image_read(file)
  img <- image_strip(img)                 # remove EXIF/ICC/etc to save space
  img <- image_convert(img, colorspace = "sRGB")  # consistent, compact profile
  
  info <- image_info(img)
  current_width <- info$width
  current_quality <- start_quality
  
  out_name <- basename(file)
  out_path <- file.path(output_dir, out_name)
  
  repeat {
    # scale to current width, then write with current quality
    img_scaled <- image_scale(img, paste0(current_width, "x"))
    image_write(img_scaled, path = out_path, format = "jpeg", quality = current_quality)
    
    size_mb <- bytes_to_mb(file.info(out_path)$size)
    
    # done if under target OR we've hit both floor limits
    if (size_mb <= max_mb || (current_width <= min_width && current_quality <= min_quality)) break
    
    # First try lowering quality down to min_quality,
    # then (if needed) start shrinking width.
    if (current_quality > min_quality) {
      current_quality <- max(min_quality, current_quality - 5)
    } else if (current_width > min_width) {
      current_width <- max(min_width, round(current_width * resize_step))
    } else {
      break
    }
  }
  
  message(sprintf("Saved %s (%.2f MB, width %d, quality %d)",
                  out_name, size_mb, current_width, current_quality))
}

# ---- run ----
input_folder  <- "/Users/michaelesbach/Documents/Research/DISES/Website/DISES-Website/images/photos"
output_folder <- "/Users/michaelesbach/Documents/Research/DISES/Website/DISES-Website/images/photos/web2"
dir.create(output_folder, showWarnings = FALSE)

jpg_files <- list.files(input_folder, pattern = "\\.jpe?g$", full.names = TRUE)
invisible(lapply(jpg_files, convert_jpg_adaptive, output_dir = output_folder))
