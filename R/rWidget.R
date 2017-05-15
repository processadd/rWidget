
#' Get relative path for dependency
#'
#' @param dependency a dependency of html content
#'
#' @param mustWork If \code{TRUE} and \code{dependency} does not point to a
#'   directory on disk (but rather a URL location), an error is raised. If
#'   \code{FALSE} then non-disk dependencies are returned without modification.
#'
#' @return url path corresponding to that dependency
getDependencyDir <- function(dependency, mustWork = TRUE) {

  dir <- dependency[["src"]][["file"]]

  if (is.null(dir)) {
    if (mustWork) {
      stop("Dependency ", dependency$name, " ", dependency$version, " is not disk-based")
    } else {
      return(dependency)
    }
  }

  target_dir <- if (getOption('htmltools.dir.version', TRUE)) {
    paste(dependency$name, dependency$version, sep = "-")
  } else dependency$name

  target_dir <- paste(file.path(target_dir), "/", sep = "")
  target_dir
}

#' Get dependency html text format
#'
#' @param html HTML content
#'
#' @param url url to store dependencies
#'
#' @param basePath folder under \code{url} to store dependencies
#'
#' @param srcType The type of src paths to use; valid values are \code{file} or
#'   \code{href}.
#'
#' @param encodeFunc The function to use to encode the path part of a URL. The
#'   default should generally be used.
#'
#' @return dependencies in HTML text format
#'
#' @export
getDependencies <- function(html,
                            url = "",
                            basePath = "",
                            srcType = c("href", "file"),
                            encodeFunc = htmltools::urlEncodePath) {
  if(is.na(url)) url <- "" #in stored proc, empty string is taken as NA
  if(is.na(basePath)) basePath <- ""
  urlBase <- paste(gsub("/*$", "", url), basePath, sep = "/")
  urlBase <- paste(gsub("/*$", "", urlBase), "/", sep = "") # needs to end with / to add dependency path

  htmlText <- c()
  rendered <- htmltools::renderTags(html)

  for (dep in rendered$dependencies) {
    dependencyDirPart <- getDependencyDir(dep)
    usableType <- srcType[which(srcType %in% names(dep$src))]
    if (length(usableType) == 0)
      stop("Dependency ", dep$name, " ", dep$version,
           " does not have a usable source")
    dir <- dep$src[head(usableType, 1)]
    srcpath <- if (usableType == "file") {
      encodeFunc(dir)
    } else {
      # Assume that href is already URL encoded
      href_path(dep)
    }
    # Drop trailing /
    srcpath <- sub("/$", "\\1", srcpath)
    # add stylesheets
    if (length(dep$stylesheet) > 0) {
      htmlText <- c(htmlText, paste(
        "<link href=\"",
        urlBase, dependencyDirPart,
        dep$stylesheet,
        "\" rel=\"stylesheet\" />",
        sep = ""))
    }
    # add scripts
    if (length(dep$script) > 0) {
      htmlText <- c(htmlText, paste(
        "<script src=\"",
        urlBase, dependencyDirPart,
        dep$script,
        "\"></script>",
        sep = ""))
    }
    if (length(dep$attachment) > 0) {
      if (is.null(names(dep$attachment)))
        names(dep$attachment) <- as.character(1:length(dep$attachment))
      htmlText <- c(htmlText,
                sprintf("<link id=\"%s-%s-attachment\" rel=\"attachment\" href=\"%s\"/>",
                        urlBase, dependencyDirPart,
                        htmlEscape(dep$name),
                        htmlEscape(names(dep$attachment)),
                        htmlEscape(file.path(srcpath, encodeFunc(dep$attachment)))))
    }
  }
  htmltools::HTML(paste(htmlText, collapse = "\n"))
}

#' Get div and data in html text format
#'
#' @param html HTML content
#'
#' @return div and data in html text format
#'
#' @export
getDivData <- function(html) {
  rendered <- htmltools::renderTags(html)
  rendered$html
}

#' Get complete html widget in html text format
#'
#' @param html HTML content
#'
#' @param url URL to store dependencies
#'
#' @param basePath folder under \code{url} to store dependencies
#'
#' @param srcType The type of src paths to use; valid values are \code{file} or
#'   \code{href}.
#'
#' @param encodeFunc The function to use to encode the path part of a URL. The
#'   default should generally be used.
#'
#' @return complete html widget in html text format
#'
#' @export
getHtmlWidget <- function(html,
                          url = "",
                          basePath = "",
                          srcType = c("href", "file"),
                          encodeFunc = htmltools::urlEncodePath){
  htmlText <- c()
  htmlText <- c(htmlText, getDivData(html))
  htmlText <- c(htmlText, getDependencies(html, url, basePath, srcType, encodeFunc))
  htmltools::HTML(paste(htmlText, collapse = "\n"))
}

