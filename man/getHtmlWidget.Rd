% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rWidget.R
\name{getHtmlWidget}
\alias{getHtmlWidget}
\title{Get complete html widget in html text format}
\usage{
getHtmlWidget(html, url = "", basePath = "", srcType = c("href", "file"),
  encodeFunc = urlEncodePath)
}
\arguments{
\item{html}{HTML content}

\item{url}{URL to store dependencies}

\item{basePath}{folder under \code{url} to store dependencies}

\item{srcType}{The type of src paths to use; valid values are \code{file} or
\code{href}.}

\item{encodeFunc}{The function to use to encode the path part of a URL. The
default should generally be used.}
}
\value{
complete html widget in html text format
}
\description{
Get complete html widget in html text format
}

