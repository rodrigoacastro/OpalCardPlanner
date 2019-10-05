## Opal planner

rm(list=ls())
ls()
dir()
list.files()

# packages and functions

library(tidyverse)
source("opal_planner_functions.r")


# main variables

current_credit = 17
# auto_topup = 10	
# lower_limit = 10	
# one_way_fare = 2.52
# # fare1 = 2
# return_fare = 2.52
# # fare2 = 1.5
# manual_topup = 0

# inputing dates
dates = c("01-10-2019","08-10-2019","15-10-2019","22-10-2019","29-10-2019")

# creates model tibble
model_tibble = data.frame(
                    #date="01-10-2019",
                    dates = dates,
                    previous_total = round(0,2),
                    partial_total = round(0,2),
                    new_credit = round(0,2)) %>%
                    as_tibble

# input initial credit
model_tibble[1,"previous_total"] = current_credit

# update table by deducting the fares

new_tibble1 = calculate_opal_fares_simple (model_tibble,line,lower_limit=10,
                                           auto_topup = 20,
                                           one_way_fare=2.52, return_fare=2.52)

new_tibble1

new_tibble2 = calculate_opal_fares_topup (model_tibble,line,lower_limit=10,
                               one_way_fare=2.52, return_fare=2.3,
                               auto_topup = 15,
                               manual_topup=20, date_topup="01-10-2019") 
new_tibble2  

###############################################################

# Future ideas
# Include ammount of separate fares perhaps per date
# Mode 1 - OpalTripPlanner - providing information, but without access to the account
# Mode 2 - Acessing the Opal website, collecting key information (autotop, lower limit, current ammount), and using it for the calculation
# 
# maybe use
# https://github.com/dsymonds/opal
