# write a site-wide auth rule
redirects <- "/*    401!"
writeLines(redirects, "_redirects")
