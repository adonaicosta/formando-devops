resource "shell_script" "scripts" {
  lifecycle_commands {
    create = file("${path.module}/scripts/create.sh")
    delete = file("${path.module}/scripts/delete.sh")    
    update = file("${path.module}/scripts/update.sh")    
  }

  working_directory = "${path.module}"

  environment = {
    install_pkgs   = var.install_pkgs
    uninstall_pkgs = var.uninstall_pkgs
    version_pkgs   = var.version_pkgs  
  }
}
