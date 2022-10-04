variable "nome" {
    description = "Seu Nome"
    type        = string    
}

variable "data" {
    description = "Dia"
    type        = number        
}

variable "div" {
    description = "Divisor"
    type        = number    
}

variable "div_list" {
    description = "Lista de Divisores"
    type        = list(number)
}

variable "div_index" {
    description  = "Index para elementos da lista"
    type         = number 
    default      = 0  
}

variable "index" {
    description = "Index 1 a 100"
    type        = number    
}
