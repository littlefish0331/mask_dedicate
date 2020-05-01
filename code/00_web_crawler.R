rm(list = ls()); gc()
setwd("E:/NCHC/project_big/mask_dedicate/")
library(dplyr)
library(data.table)
library(jsonlite)
library(lubridate)

# ---
webcrawler <- function(crawl_date){
  detail <- list()
  i <- 1
  keep_go <- 1
  url <- paste0("https://taiwancanhelp.com.tw/api/mask", "?date=", crawl_date, "&show=1000")
  while(keep_go==1){
    response = fromJSON(url)
    detail[[i]] <- response$data$list %>% setDT %>% .[, !"_created"]
    i <- i+1
    
    # ---
    if (is.null(response$data$next_api)) {
      keep_go <- 0
      dailysummary <- data.table(date = response$data$date, 
                                 total_masks = response$data$total_masks, 
                                 total_dedicators = response$data$total_dedicators)
    }
    else url <- url %>% gsub("(.*)/api.*", paste0("\\1", response$data$next_api), .)
    Sys.sleep(0.5)
  }
  
  res <- list(detail = detail, dailysummary = dailysummary)
  return(res)
}

# ---
# 要爬取的日期列表
date_start <- "2020/04/27" %>% ymd
date_end <- Sys.time() %>% substring(., 1, 10) %>% ymd() %>% `-`(1)
date_all <- seq(date_start, date_end, by = "days")
if (file.exists("./data/dailysummary.csv")){
  tmp <- fread("./data/dailysummary.csv")
} else {
  tmp <- NULL
}
date_vec <- date_all[!date_all %in% ymd(tmp$date)]

for (date_i in 1:length(date_vec)) {
  crawl_date <- date_vec[date_i] %>% gsub("-", "/", .)
  res <- webcrawler(crawl_date = crawl_date)
  
  detail_all <- res$detail %>% rbindlist()
  nn <- paste0("detail_", date_vec[date_i], ".csv")
  fwrite(x = detail_all, file = paste0("./data/", nn), row.names = F)
  
  # ---
  fwrite(x = res$dailysummary, file = "./data/dailysummary.csv", row.names = F, append = T)
}


# ---
# 如果 dailysummary 要不斷覆寫，記得tmp要更新
# dailysummary_add <- list(tmp, res$dailysummary) %>% rbindlist()
# tmp <- dailysummary_add
# fwrite(x = dailysummary_add, file = "./data/dailysummary.csv", row.names = F)


