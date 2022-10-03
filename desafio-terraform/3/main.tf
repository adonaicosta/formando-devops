provisioner "file" {
  source      = templatefile("alo_mundo.txt.tpl", {nome = var.nome, data = var.data, div = var.div})
  destination = "alo_mundo.txt"
}