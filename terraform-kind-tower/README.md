## terraform-kind-tower

Automated flow to deploy [Tower](https://github.com/seqeralabs/nf-tower) and expose it externally.

This module will automate the full setup of a kubernetes [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/) cluster.
The idea is to provide a fully autmated solution, that will setup eveything from scratch with one single command *setup\_cluster.sh*

Since this solution requires to have an automatic way for updating the application, I am using ArgoCD, which is also automated installed and configured, to setup syncronization with the offical Tower helm chart.

## Requirements

\_Note: The following is required for the solution to work.\_

* [Terraform](https://www.terraform.io)
* [Kubectl](https://kubernetes.io/es/docs/tasks/tools/)
* [Docker](https://docs.docker.com/engine/install/ubuntu/)

## How it works

This is all done using HashiCorp Terraform as the main language/tool.
By using this appreach, we simplify and centralice the solution setup.

It first deploy a Kubernetes [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/) cluster, then it deploys the basic ingress/monitoring stack based in [NGINX ingress](https://docs.nginx.com/nginx-ingress-controller/) and [Prometheus/Grafana](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack).
After, it deploys [Cert-Manager](https://cert-manager.io) for the TLS automation. Since, Ingress with TLS is another requirement.

Whith all the above in place, then I deploy [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) with the ImmudDB application deployed to ArgoCD.

## Example Usage

```hcl
# main.tf
module "terraform-kind-tower" {
  source                        = "github.com/Enekui/terraform-kind-tower"
  argocd_ingress_host           = "argocd.example.com"
  grafama_ingress_host          = "grafana.example.com"
  grafana_adminpassword         = "myPassword"
}
```

```shell
terraform init
terraform apply -auto-approve
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_argocd"></a> [argocd](#requirement\_argocd) | 4.1.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.7.1 |
| <a name="requirement_kind"></a> [kind](#requirement\_kind) | 0.0.2-u2 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 1.13.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.15.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.9.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.7.1 |
| <a name="provider_kind"></a> [kind](#provider\_kind) | 0.0.2-u2 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.13.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.15.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.9.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/2.7.1/docs/resources/release) | resource |
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/2.7.1/docs/resources/release) | resource |
| [helm_release.ingress_nginx](https://registry.terraform.io/providers/hashicorp/helm/2.7.1/docs/resources/release) | resource |
| [helm_release.prometheus](https://registry.terraform.io/providers/hashicorp/helm/2.7.1/docs/resources/release) | resource |
| [kind_cluster.this](https://registry.terraform.io/providers/unicell/kind/0.0.2-u2/docs/resources/cluster) | resource |
| [kubectl_manifest.cluster_issuer](https://registry.terraform.io/providers/gavinbunney/kubectl/1.13.0/docs/resources/manifest) | resource |
| [kubernetes_namespace_v1.tower](https://registry.terraform.io/providers/hashicorp/kubernetes/2.15.0/docs/resources/namespace_v1) | resource |
| [time_sleep.wait](https://registry.terraform.io/providers/hashicorp/time/0.9.1/docs/resources/sleep) | resource |
| [kubernetes_secret_v1.argocd_admin](https://registry.terraform.io/providers/hashicorp/kubernetes/2.15.0/docs/data-sources/secret_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_ingress_host"></a> [argocd\_ingress\_host](#input\_argocd\_ingress\_host) | Ingress host to expose ArgoCD server UI | `string` | n/a | yes |
| <a name="input_grafama_ingress_host"></a> [grafama\_ingress\_host](#input\_grafama\_ingress\_host) | Ingress host to expose Grafana UI | `string` | n/a | yes |
| <a name="input_grafana_adminpassword"></a> [grafana\_adminpassword](#input\_grafana\_adminpassword) | Grafana UI administrator password | `string` | n/a | yes |
| <a name="input_cert_manager_cluster_issuer_server"></a> [cert\_manager\_cluster\_issuer\_server](#input\_cert\_manager\_cluster\_issuer\_server) | ClusterIssuer server to validate cert-manager TLS certificates | `string` | `"https://acme-v02.api.letsencrypt.org/directory"` | no |
| <a name="input_cert_manager_version"></a> [cert\_manager\_version](#input\_cert\_manager\_version) | Cert-Manager chart version. | `string` | `"1.7.1"` | no |
| <a name="input_ingress_nginx_version"></a> [ingress\_nginx\_version](#input\_ingress\_nginx\_version) | NGINX Ingress Controller chart version | `string` | `"4.3.0"` | no |
| <a name="input_kind_cluster_name"></a> [kind\_cluster\_name](#input\_kind\_cluster\_name) | The kind name that is given to the created cluster. | `string` | `"kind-cluster"` | no |
| <a name="input_kind_node_image"></a> [kind\_node\_image](#input\_kind\_node\_image) | The node\_image that kind will use (ex: kindest/node:v1.25) | `string` | `"kindest/node:v1.25.2"` | no |
| <a name="input_kind_pod_subnet"></a> [kind\_pod\_subnet](#input\_kind\_pod\_subnet) | The Pods subnet CIDR to use inside the kind cluster | `string` | `"10.244.0.0/16"` | no |
| <a name="input_kind_wait_for_ready"></a> [kind\_wait\_for\_ready](#input\_kind\_wait\_for\_ready) | Defines wether or not the provider will wait for the control plane to be ready. Defaults to false. | `bool` | `true` | no |
| <a name="input_prometheus_version"></a> [prometheus\_version](#input\_prometheus\_version) | Prometheus stack chart version | `string` | `"41.7.3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd-initial-admin-secret"></a> [argocd-initial-admin-secret](#output\_argocd-initial-admin-secret) | ArgoCD initial admin secret |