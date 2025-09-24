terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Variables
variable "project" { default = "demo-js" }
variable "app"     { default = "js-app" }
variable "image"   { default = "node:18-alpine" }

# Namespace
resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = var.project
  }
}

# Deployment JS App
resource "kubernetes_deployment_v1" "deploy" {
  metadata {
    name      = var.app
    namespace = var.project
    labels = {
      app = var.app
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = var.app
      }
    }

    template {
      metadata {
        labels = {
          app = var.app
        }
      }

      spec {
        container {
          name  = var.app
          image = var.image

          command = [
            "node",
            "-e",
            "require('http').createServer((req,res)=>res.end('Hello from JS App!')).listen(3000)"
          ]

          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

# Service exposing port 3000
resource "kubernetes_service_v1" "svc" {
  metadata {
    name      = var.app
    namespace = var.project
  }

  spec {
    selector = {
      app = var.app
    }

    port {
      name        = "http"
      port        = 3000
      target_port = 3000
    }

    type = "ClusterIP"
  }
}