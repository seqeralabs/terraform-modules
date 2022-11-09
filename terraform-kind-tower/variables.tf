## Kind
variable "kind_cluster_name" {
  type        = string
  description = "The kind name that is given to the created cluster."
  default     = "kind-cluster"
}

variable "kind_node_image" {
  type        = string
  description = "The node_image that kind will use (ex: kindest/node:v1.25)"
  default     = "kindest/node:v1.25.2"
}

variable "kind_pod_subnet" {
  type        = string
  description = "The Pods subnet CIDR to use inside the kind cluster"
  default     = "10.244.0.0/16"
}

variable "kind_wait_for_ready" {
  type        = bool
  description = "Defines wether or not the provider will wait for the control plane to be ready. Defaults to false."
  default     = true
}

## NGINX Ingress Controller
variable "ingress_nginx_version" {
  type        = string
  default     = "4.3.0"
  description = "NGINX Ingress Controller chart version"
}

## Prometheus
variable "prometheus_version" {
  type        = string
  default     = "41.7.3"
  description = "Prometheus stack chart version"
}

## Grafana
variable "grafama_ingress_host" {
  type        = string
  description = "Ingress host to expose Grafana UI"
}

variable "grafana_adminpassword" {
  type        = string
  description = "Grafana UI administrator password"
}



## Cert-Manager
variable "cert_manager_cluster_issuer_server" {
  type        = string
  description = "ClusterIssuer server to validate cert-manager TLS certificates"
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "cert_manager_version" {
  type        = string
  default     = "1.7.1"
  description = "Cert-Manager chart version."
}


## ArgoCD 
variable "argocd_ingress_host" {
  type        = string
  description = "Ingress host to expose ArgoCD server UI"
}

## Tower
variable "tower_server_url" {
  type        = string
  description = "The url where Tower ingress will expose the endpoint"
}

variable "tower_contact_email" {
  type        = string
  description = "Email contact information for Tower"
  default     = "support@tower.nf"
}

variable "tower_enable_unsafe_mode" {
  type        = string
  description = "Enable or disable Tower unsafe mode"
  default     = "true"
}

variable "tower_jwt_secret" {
  type        = string
  description = "Tower json web token secret"
  default     = "ReplaceThisWithALongSecretString123456789012345678901234567890"
}

variable "tower_smtp_user" {
  type        = string
  description = "SMTP user for Tower email capabilities"
}

variable "tower_smtp_password" {
  type        = string
  description = "SMTP password to authenticate Tower"
  sensitive   = true
}

variable "tower_smtp_host" {
  type        = string
  description = "SMTP host for Tower email capabilities"
}

variable "tower_krypto_secret_key" {
  type        = string
  description = "Tower kryptogaph secret key value"
}

variable "tower_enable_paltforms" {
  type        = string
  description = "Platform to enable on Tower"
  default     = "local-platform,awsbatch-platform,gls-platform,slurm-platform,lsf-platform,scm-config,openapi,k8s-platform,eks-platform,gke-platform,uge-platform,altair-platform,azbatch-platform"
}

variable "tower_db_url" {
  type           = string
  desdescription = "Mysql DB host url"
  default        = "jdbc:mysql://mysql:3306/tower"
}

variable "tower_db_driver" {
  type        = string
  description = "Mysql db driver"
  default     = "org.mariadb.jdbc.Driver"
}

variable "tower_db_dialect" {
  type        = string
  description = "Database dialect for Tower configuration"
  default     = "io.seqera.util.MySQL55DialectCollateBin"
}

variable "tower_db_user" {
  type        = string
  description = "User to authenticate to Mysql Tower db"
  default     = "tower"
}

variable "tower_db_password" {
  type        = string
  description = "Mysql tower user password"
  default     = "tower"
  sensitive   = true
}

variable "flyway_locations" {
  type        = string
  description = "Fly way locations configuration"
  default     = "classpath:db-schema/mysql"
}

variable "tower_license" {
  type        = string
  description = "Tower license key"
}

variable "tower_frontend_image" {
  type        = string
  description = "Tower frontend image registry and tag"
}

variable "tower_backend_image" {
  type        = string
  description = "Tower backend image registry and tag"
}



