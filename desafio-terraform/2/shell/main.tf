variable "install_pkgs" {
  description = "Packages to Install"
  type        = string  
}

variable "uninstall_pkgs" {
  description = "Packages to Uninstall"
  type        = string  
}

variable "version_pkgs" {
  description = "Especific Version"
  type        = string  
}

resource "shell_script" "scripts" {
  lifecycle_commands {
    create = file("./scripts/create.sh")
    delete = file("./scripts/delete.sh")    
    update = file("./scripts/update.sh")    
  }
}
