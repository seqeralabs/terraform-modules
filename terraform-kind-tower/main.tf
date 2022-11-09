## Kind
resource "kind_cluster" "this" {
  name           = var.kind_cluster_name
  node_image     = var.kind_node_image
  wait_for_ready = var.kind_wait_for_ready
  kind_config    = <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
networking:
  podSubnet: "${var.kind_pod_subnet}"
EOF
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.ingress_nginx_version

  values = [<<EOF
controller:
  hostPort:
    enabled: true
  service:
    type: NodePort
  watchIngressWithoutClass: true
  nodeSelector:
    ingress-ready: "true"
  tolerations:
    - key: "node-role.kubernetes.io/master"
      operator: "Equal"
      effect: "NoSchedule"
    - key: "node-role.kubernetes.io/control-plane"
      operator: "Equal"
      effect: "NoSchedule"
  publishService:
    enabled: false
  extraArgs:
    publish-status-address: localhost
EOF
  ]

  depends_on = [
    resource.kind_cluster.this
  ]
}

## Cert Manager
resource "helm_release" "cert_manager" {
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  name       = "cert-manager"
  namespace  = "cert-manager"
  version    = var.cert_manager_version

  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [
    resource.kind_cluster.this
  ]
}

resource "time_sleep" "wait" {
  create_duration = "60s"

  depends_on = [helm_release.cert_manager]
}

resource "kubectl_manifest" "cluster_issuer" {
  validate_schema = false
  force_new       = true

  yaml_body = <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: cert-manager-global
spec:
  acme:
    server: ${var.cert_manager_cluster_issuer_server}
    privateKeySecretRef:
      name: cert-manager-private-key
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

  depends_on = [
    helm_release.cert_manager,
    time_sleep.wait
  ]
}

## Prometheus
resource "helm_release" "prometheus" {
  name             = "prometheus"
  namespace        = "monitoring"
  create_namespace = true
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = var.prometheus_version

  values = [<<EOF
alertmanager:
  enabled: false
grafana:
  enabled: true
  adminPassword: ${var.grafana_adminpassword}
  ingress:
    enabled: true
    ingressClassName: nginx
    annotations: 
      "nginx.ingress.kubernetes.io/ssl-passthrough": "true"
      "kubernetes.io/tls-acme": "true"
      "cert-manager.io/cluster-issuer": "cert-manager-global"
    hosts:
      - ${var.grafama_ingress_host}
    path: /
    tls:
    - secretName: grafana-general-tls
      hosts:
      - ${var.grafama_ingress_host}
EOF
  ]

  depends_on = [
    resource.kind_cluster.this,
    resource.helm_release.cert_manager,
    resource.kubectl_manifest.cluster_issuer
  ]
}

## ArgoCD
resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"

  values = [<<EOF
server:
  extraArgs: 
    - "--insecure"
  ingress:
    enabled: true
    annotations: 
      "nginx.ingress.kubernetes.io/ssl-passthrough": "true"
      "kubernetes.io/tls-acme": "true"
      "cert-manager.io/cluster-issuer": "cert-manager-global"
    ingressClassName: "nginx"
    hosts:
      - ${var.argocd_ingress_host}
    paths:
      - /
    pathType: Prefix
    tls:
      - secretName: argocd-tls
        hosts:
          - ${var.argocd_ingress_host}
EOF
  ]
  depends_on = [
    resource.kind_cluster.this,
    resource.helm_release.cert_manager,
    resource.kubectl_manifest.cluster_issuer
  ]
}

## Tower
resource "kubernetes_namespace_v1" "tower" {
  metadata {

    labels = {
      app = "tower"
    }
    name = "tower"
  }
}

# resource "argocd_application" "tower" {
#   metadata {
#     name      = "tower"
#     namespace = "argocd"
#   }

#   wait = true
#   spec {
#     project = "default"

#     destination {
#       namespace = "tower"
#       server    = "https://kubernetes.default.svc"
#     }

#     source {

#     }

#     sync_policy {
#       automated = {
#         "allow_empty" = false
#         "prune"       = true
#         "self_heal"   = true
#       }
#       sync_options = []
#     }
#   }

#   lifecycle {
#     replace_triggered_by = [
#       resource.helm_release.argocd
#     ]
#   }

#   depends_on = [
#     resource.kind_cluster.this,
#     resource.helm_release.argocd
#   ]
# }
