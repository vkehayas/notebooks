blogDir = "~/git/neurathsboat.blog/"

filesList = dir()
mdInd = grepl(".md", filesList, fixed = TRUE)
mdFiles = filesList[mdInd]

ReplacePath = function(fileName) {
  fileIn = readLines(fileName)
  yamlInd = grep("---", fileIn)
  strippedOfHeader = fileIn[(yamlInd[2] + 1):length(fileIn)]
  newHeader = readLines("header")
  fileWithNewHeader = c(newHeader, strippedOfHeader)
  fileOut = gsub("img", "/img", fileWithNewHeader)
  writeLines(fileOut, fileName)
}

lapply(mdFiles, ReplacePath)
# system(paste("rsync -ahvz", mdFiles, paste0(blogDir, "content/post/")))
system(paste("rsync -ahvz img/*", paste0(blogDir, "static/img/")))
