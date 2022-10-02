provider "shell" {
      source = "scottwinkler/shell"
      version = "1.7.7"     
}

variable "install_pkgs" {
  description = "Packages to Install"
  type        = string  
}

variable "uninstall_pkgs" {
  description = "Packages to Uninstall"
  type        = string  
}

resource "shell_script" "scripts" {
  lifecycle_commands {
    create = file("create.sh")
    delete = file("delete.sh")    
    update = file("update.sh")    
  }
}