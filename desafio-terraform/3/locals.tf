locals {  
    iterator = {          
      for i in range(100) :              
        condition (i%div == 0 ? div_list[div_index] = i &&
        div_index = div_index + 1:)       
      }
}
