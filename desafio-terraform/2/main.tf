provider shell {
      source = "scottwinkler/shell"
      version = "1.7.7"
}

resource "shell_script" "scripts" {
  lifecycle_commands {
    create = file("./scripts/create.sh")
    read   = file("./scripts/read.sh")
    update = file("./scripts/update.sh")
    delete = file("./scripts/delete.sh")
  }
}
