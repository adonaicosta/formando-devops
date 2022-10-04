locals {  
    iterator = {          
      for i in range(100) :
        index = i        
        condition (index%div == 0 ? div_list[div_index] = div &&
        div_index = div_index + 1:)       
      }
}
