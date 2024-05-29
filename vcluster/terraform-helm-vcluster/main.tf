provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "my_vcluster" {
  name             = "terraform-vcluster"
  namespace        = "terraform-vcluster"
  create_namespace = true

  repository       = "https://charts.loft.sh"
  chart            = "vcluster"
  version          = "0.20.0-beta.5"

  values = [
    "${file("vcluster.yaml")}"
  ]
}