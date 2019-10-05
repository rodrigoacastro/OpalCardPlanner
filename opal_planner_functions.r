# opal_planner_functions

# creates infix operator
`%+=%` = function(e1,e2) eval.parent(substitute(e1 <- e1 + e2))

############################################

# update partial_total and new_credit

# update_totals0 = function(tibble, line) {
#   tibble[line,] %>% 
#     mutate(partial_total = previous_total - one_way_fare) %>%
#     #mutate(minus_one_way_fare = previous_total - fare1)
#     mutate(new_credit = partial_total - return_fare)
#     #mutate(minus_one_way_fare = previous_total - fare2)
#   
# }

###################

# update_totals

###################
# function to update functions and apply autotopup if needed

# debugging
# tibble = model_tibble
# line = 2

update_totals = function(tibble, line,lower_limit=10,
                         one_way_fare=2.52, return_fare=2.52,auto_topup=10) {
  
  # charges one_way_fare
  tibble[line,] = tibble[line,] %>% 
    mutate(partial_total = previous_total - one_way_fare)
  #mutate(minus_one_way_fare = previous_total - fare1)
  
  
  # checks if partial total is below the lower limit and updates  
  if (tibble[line,"partial_total"] < lower_limit) {
    tibble[line,] = tibble[line,] %>% 
      mutate(partial_total = partial_total + auto_topup)
  }
  
  # charges return_fare
  tibble[line,] = tibble[line,] %>% 
    mutate(new_credit = partial_total - return_fare)
  #mutate(minus_one_way_fare = previous_total - fare2)
  
  # checks if new credit is below the lower limit and updates  
  if (tibble[line,"new_credit"] < lower_limit) {
    tibble[line,] = tibble[line,] %>% 
      mutate(new_credit = new_credit + auto_topup)
  }
  return(tibble)
}
############################################

# calculate_opal_fares

#############################################
# based on the function update_totals(), 
# this function calculates opal fares for each line

calculate_opal_fares_simple = function (tibble,line,lower_limit=10,
                                 one_way_fare=2.52, return_fare=2.52,auto_topup=10) {
  
  for ( line in seq_along(1:nrow(tibble)) ) {
    
    # updates previous total with previous final credit
    if (line > 1) {
      tibble[line,"previous_total"] = tibble[line-1,"new_credit"]
    }
    
    # update total in line
    tibble = update_totals (tibble, line,lower_limit,
                            one_way_fare, return_fare,auto_topup = auto_topup)
    
    
  }
  
  return(tibble)
  
}
#############################################

# tibble = model_tibble
# line=1
# date_topup = ""
# date_topup = "01-10-2019"

calculate_opal_fares_topup = function (tibble,line,lower_limit=10,
                                 one_way_fare=2.52, return_fare=2.52,
                                 auto_topup = 10,
                                 manual_topup=0, date_topup="") {
  # create manual_topup column
  tibble$manual_topup = "no"
  
  
  
  # check if topup is okay, if it is empty or if date is invalid
  if (date_topup == "" | !date_topup %in% tibble$dates) {
    alert = "date of topup not found"
      
  } else {
      # find line number of the topup
      line_numb = grep (pattern = date_topup,x = tibble$dates)
  } 
  

  # in each line  
  for ( line in seq_along(1:nrow(tibble)) ) {
    
      # updates previous total with previous final credit
      if (line > 1) {
        tibble[line,"previous_total"] = tibble[line-1,"new_credit"]
      }
      
      # update total in line
      tibble = update_totals (tibble, line,lower_limit,
                              one_way_fare, return_fare, auto_topup = auto_topup)
      
      # if a topup happened (and is not zero), apply it in the new_credit column
      if (line == line_numb & manual_topup != 0) {
        tibble[line_numb,"new_credit"] = tibble[line_numb,"new_credit"] + manual_topup
        # fill top up column in this line
        tibble[dates == date_topup,"manual_topup"] = "yes"
      }   
   } # end of for
      
 
  # return error and tibble if topup date not found, else just tibble
  if (!date_topup %in% tibble$dates) {
    return(list(alert,tibble))
  } else {
    return(tibble)
  }
  
  
}

########

# testing

# final = calculate_opal_fares_topup (model_tibble,line,lower_limit=10,
#                        one_way_fare=2.52, return_fare=2.52, 
#                        manual_topup=5, date_topup="01-10-2019") 
# final  

#######################################################################