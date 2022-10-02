variable "install_pkg" {
  description = "Packages to Install"
  type        = string  
}

variable "uninstall_pkg" {
  description = "Packages to Uninstall"
  type        = string  
}

resource "shell_script" "scripts" {
  lifecycle_commands {
    create = file("./scripts/create.sh")
    delete = file("./scripts/delete.sh")    
    update = file("./scripts/update.sh")    
  }
}