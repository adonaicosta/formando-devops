resource "shell_script" "install" {
  lifecycle_commands {
    create = <<-EOF
            apt install
        EOF
    delete = ""
  }
}

