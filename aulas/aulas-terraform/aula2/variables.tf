variable "blocks" {
    type = list(object({
        device_name = string
        volume_size = string
        volume_type = string
    }))
    description = "list of ebs blocks variables constraints"
}
