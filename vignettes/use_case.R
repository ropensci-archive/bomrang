## ----load_libraries_hidden, eval=TRUE, echo=FALSE, message=FALSE, results='hide'----
library(bomrang)

## ----install_packages, eval=FALSE----------------------------------------
#  install.packages("bomrang")
#  install.packages("mailR")
#  library(dplyr)  # filter()
#  library(bomrang)
#  library(mailR)

## ----suscribers, eval=TRUE-----------------------------------------------
subscribers_list <-
  data.frame(cbind(
    c(1, 2, 3),
    c("Joe", "John", "Jayne"),
    c("Blogs", "Doe", "Doe"),
    c("Dalby", "Toowoomba", "Warwick"),
    c(
      "XXXX.XXXX@gmail.com",
      "XXXX.XXXX@hotmail.com",
      "123.123@gmail.com"
    )
  )
  )
colnames(subscribers_list) <-
  c("Entry","Name","Surname","Location","email")
head(subscribers_list)

## ----our_email, eval=FALSE-----------------------------------------------
#  our_email <- "yyyy***xxxx@gmail.com"
#  our_password <- "*password*"

## ----threshold, eval=FALSE-----------------------------------------------
#  threshold_temp <- 40

## ----forecast, eval=FALSE------------------------------------------------
#  QLD_forecast <- get_precis_forecast(state = "QLD")

## ----for_loop, eval=FALSE------------------------------------------------
#  QLD_hotdates <-
#    QLD_forecast %>%
#    filter(maximum_temperature >= threshold_temp)
#  
#  for (x in seq_len(nrow(subscribers_list))) {
#    subscriber_location <- subscribers_list[["Location"]][x]
#    if (subscriber_location %in% QLD_hotdates[["town"]]) {
#      hot_dates <-
#        paste(gsub("00:00:00", "", QLD_hotdates$start_time_local), collapse = ", ")
#  
#      body_text <-
#        paste(
#          "\nHello ", as.character(subscribers_list$Name[x]), ".\n",
#          "\nYour mungbean crops at ", subscriber_location,
#          "\nare forecast to be exposed to heat stress on the\n",
#          "\nfollowing dates: ", hot_dates, ".\n",
#          "\nConsider irrigating your crops beforehand to\n"
#          "\nfacilitate transpirational cooling.\n",
#          "\nFrom the WINS team\n"
#        )
#      recipient <-
#        as.character(subscribers_list$email[x])
#      send.mail(
#        from = our_email,
#        to = recipient,
#        subject = "Mungbean Heat Stress Warning",
#        body = body_text,
#        smtp = list(
#          host.name = "smtp.gmail.com",
#          port = 465,
#          user.name = our_email,
#          passwd = our_password,
#          ssl = TRUE
#        ),
#        authenticate = TRUE,
#        send = TRUE
#      )
#    }
#  }

