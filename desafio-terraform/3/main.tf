provisioner "file" {
  source      = templatefile("alo_mundo.txt.tpl", {nome = var.nome, data = var.data, div = var.div, div_list = var.div_list})
  destination = "alo_mundo.txt"
}