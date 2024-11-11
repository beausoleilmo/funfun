library(tidyverse)
# Max nutidyverse# Max number of letters
max = 26
v.c = c(letters[1:max], # Letters selected 
        " ") # Add a space 
vcl = length(v.c) # Check length of vector 
prob.space = 1.3 # Probability to be shared 
1-(1/prob.space)
# Extract label and state probability of letters vs space 
pointer = sample(x = 1:c(vcl), 
                 prob = c(rep((vcl*1/prob.space)/vcl/max, max), 1-(1/prob.space)),
                 size = 1000, # Size of the # of characters 
                 replace = T)

# Lorem Ipsum but with random stuff
(sent = paste0(v.c[pointer], collapse = "") |> str_squish())
# Numbe rof characters 
nchar(sent)
