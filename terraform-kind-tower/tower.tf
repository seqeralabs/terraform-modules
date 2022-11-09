resource "kubernetes_config_map" "tower_backend_cfg" {
  metadata {
    name = "tower-backend-cfg"

    labels = {
      app = "backend-cfg"
    }
  }

  data = {
    FLYWAY_LOCATIONS         = var.flyway_locations
    TOWER_CONTACT_EMAIL      = var.tower_contact_email
    TOWER_CRYPTO_SECRETKEY   = var.tower_krypto_secret_key
    TOWER_DB_DIALECT         = var.tower_db_dialect
    TOWER_DB_DRIVER          = var.tower_db_driver
    TOWER_DB_PASSWORD        = var.tower_db_password
    TOWER_DB_URL             = var.tower_db_url
    TOWER_DB_USER            = var.tower_db_user
    TOWER_ENABLE_PLATFORMS   = var.tower_enable_paltforms
    TOWER_ENABLE_UNSAFE_MODE = var.tower_enable_unsafe_mode
    TOWER_JWT_SECRET         = var.tower_jwt_secret
    TOWER_LICENSE            = var.tower_license
    TOWER_SERVER_URL         = var.tower_server_url
    TOWER_SMTP_HOST          = var.tower_smtp_host
    TOWER_SMTP_PASSWORD      = var.tower_smtp_password
    TOWER_SMTP_USER          = var.tower_smtp_user
  }
}

resource "kubernetes_stateful_set" "mysql" {
  metadata {
    name = "mysql"

    labels = {
      app = "mysql"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }

      spec {
        container {
          name  = "mysql"
          image = "mysql:5.6"

          port {
            container_port = 3306
          }

          env {
            name  = "MYSQL_ALLOW_EMPTY_PASSWORD"
            value = "yes"
          }

          env {
            name  = "MYSQL_USER"
            value = "tower"
          }

          env {
            name  = "MYSQL_PASSWORD"
            value = "tower"
          }

          env {
            name  = "MYSQL_DATABASE"
            value = "tower"
          }
        }

        restart_policy = "Always"
      }
    }

    service_name = "mysql"
  }
}

resource "kubernetes_service" "mysql" {
  metadata {
    name = "mysql"

    labels = {
      app = "mysql"
    }
  }

  spec {
    port {
      port        = 3306
      target_port = "3306"
    }

    selector = {
      app = "mysql"
    }
  }
}

resource "kubernetes_stateful_set" "redis" {
  metadata {
    name = "redis"

    labels = {
      app = "redis"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {
        volume {
          name = "host-sys"

          host_path {
            path = "/sys"
          }
        }

        init_container {
          name    = "init-sysctl"
          image   = "busybox"
          command = ["/bin/sh", "-c", "sysctl -w net.core.somaxconn=1024;\necho never > /sys/kernel/mm/transparent_hugepage/enabled\n"]

          volume_mount {
            name       = "host-sys"
            mount_path = "/sys"
          }

          security_context {
            privileged = true
          }
        }

        container {
          name  = "redis"
          image = "public.ecr.aws/seqera-labs/redis:5.0.8"
          args  = ["--appendonly yes"]

          port {
            container_port = 6379
          }
        }

        restart_policy = "Always"
      }
    }

    service_name = "redis"
  }
}

resource "kubernetes_service" "redis" {
  metadata {
    name = "redis"

    labels = {
      app = "redis"
    }
  }

  spec {
    port {
      port        = 6379
      target_port = "6379"
    }

    selector = {
      app = "redis"
    }
  }
}

resource "kubernetes_deployment" "cron" {
  metadata {
    name = "cron"

    labels = {
      app = "cron"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "cron"
      }
    }

    template {
      metadata {
        labels = {
          app = "cron"
        }
      }

      spec {
        init_container {
          name    = "migrate-db"
          image   = var.tower_backend_image
          command = ["sh", "-c", "/migrate-db.sh"]

          env_from {
            config_map_ref {
              name = "tower-backend-cfg"
            }
          }
        }

        container {
          name  = "backend"
          image = var.tower_backend_image

          port {
            container_port = 8080
          }

          env_from {
            config_map_ref {
              name = "tower-backend-cfg"
            }
          }

          env {
            name  = "MICRONAUT_ENVIRONMENTS"
            value = "prod,redis,cron"
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = "8080"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 3
            failure_threshold     = 10
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = "8080"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 3
          }
        }

        image_pull_secrets {
          name = "reg-creds"
        }
      }
    }
  }
}

resource "kubernetes_deployment" "backend" {
  metadata {
    name = "backend"

    labels = {
      app = "backend"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "backend"
        }
      }

      spec {
        container {
          name  = "backend"
          image = var.tower_backend_image

          port {
            container_port = 8080
          }

          env_from {
            config_map_ref {
              name = "tower-backend-cfg"
            }
          }

          env {
            name  = "MICRONAUT_ENVIRONMENTS"
            value = "prod,redis,ha"
          }

          resources {
            limits = {
              memory = "4200Mi"
            }

            requests = {
              cpu = "1"

              memory = "1200Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = "8080"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 3
            failure_threshold     = 10
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = "8080"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 3
          }
        }

        image_pull_secrets {
          name = "reg-creds"
        }
      }
    }

    strategy {
      rolling_update {
        max_surge = "1"
      }
    }
  }
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"

    labels = {
      app = "frontend"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }

      spec {
        container {
          name  = "frontend"
          image = var.tower_frontend_image

          port {
            container_port = 80
          }
        }

        restart_policy = "Always"

        image_pull_secrets {
          name = "reg-creds"
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name = "backend"

    labels = {
      app = "backend"
    }
  }

  spec {
    port {
      name        = "http"
      port        = 8080
      target_port = "8080"
    }

    selector = {
      app = "backend"
    }
  }
}

resource "kubernetes_service" "backend_api" {
  metadata {
    name = "backend-api"
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 8080
      target_port = "8080"
    }

    selector = {
      app = "backend"
    }

    type = "NodePort"
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend"
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "80"
    }

    selector = {
      app = "frontend"
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "tower_ingress" {
  metadata {
    name      = "tower-ingress"
    namespace = "tower"

    annotations = {
      "cert-manager.io/cluster-issuer"              = "cert-manager-global"
      "kubernetes.io/tls-acme"                      = "true"
      "nginx.ingress.kubernetes.io/ssl-passthrough" = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [var.tower_server_url]
      secret_name = "tower-tls"
    }

    rule {
      host = var.tower_server_url

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "frontend"

              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

