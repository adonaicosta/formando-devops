resource "shell_script" "weather" {
  lifecycle_commands {
    create = <<-EOF
            apt install
        EOF
    delete = ""
  }
}

