provisioner "file" {
  source      = templatefile("alo_mundo.txt.tpl", var.nome, var.data, var.div)
  destination = "alo_mundo.txt"
}
