#### Dependencies ####
# - infrastructure/aks.tf

provider "kubernetes" {
  host                   = data.terraform_remote_state.infrastructure.outputs.aks_host
  client_certificate     = base64decode(data.terraform_remote_state.infrastructure.outputs.aks_client_certificate)
  client_key             = base64decode(data.terraform_remote_state.infrastructure.outputs.aks_client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infrastructure.outputs.aks_cluster_ca_certificate)
}

provider "kubectl" {
  host                   = data.terraform_remote_state.infrastructure.outputs.aks_host
  client_certificate     = base64decode(data.terraform_remote_state.infrastructure.outputs.aks_client_certificate)
  client_key             = base64decode(data.terraform_remote_state.infrastructure.outputs.aks_client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infrastructure.outputs.aks_cluster_ca_certificate)
  load_config_file       = false
}

#
# Namespaces
#
resource "kubernetes_namespace" "pipeline" {
  metadata {
    name = "pipeline"

    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "kubernetes_namespace" "datahub" {
  metadata {
    name = "datahub"

    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "kubernetes_namespace" "elastic-system" {
  metadata {
    name = "elastic-system"
  }
}

resource "kubernetes_namespace" "elasticsearch" {
  metadata {
    name = "elasticsearch"

    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}


#
# Secrets
#
# Not all secrets needed for the pipeline are created here. In order to minimize coupling,
# only those secrets that contain information created during the Terraform application are defined.
#
resource "kubernetes_secret" "event-hubs-creds" {
  metadata {
    name      = "event-hubs-creds"
    namespace = kubernetes_namespace.pipeline.metadata[0].name
  }

  data = {
    connection-string = module.eventhubs_mqtt.namespace_connection_string
  }

  type = "Opaque"
}

resource "kubernetes_secret" "postgres-connector-secrets" {
  metadata {
    name      = "postgres-connector-secrets"
    namespace = kubernetes_namespace.pipeline.metadata[0].name
  }

  data = {
    GDI_KEY                         = module.eventhubs_mqtt.namespace_postgres_connector_primary_key
    GDI_NAMESPACE                   = module.eventhubs_mqtt.namespace_fqn
    GDI_DB_HOST                     = module.grafana.datasci_fqdn
    GDI_DB_USER                     = format("%s@%s", module.grafana.datasci_login, module.grafana.datasci_server_name)
    GDI_DB_PASSWORD                 = module.grafana.datasci_password
    GDI_CHECKPOINT_STORE_CONNECTION = module.grafana.gfi_storage_account_connection_string
    GDI_CHECKPOINT_STORE_CONTAINER  = module.grafana.gfi_storage_container_name
  }

  type = "Opaque"
}

resource "kubernetes_secret" "postgres-alert-connector-secrets" {
  metadata {
    name      = "postgres-alert-connector-secrets"
    namespace = kubernetes_namespace.pipeline.metadata[0].name
  }

  data = {
    GDI_KEY                         = module.eventhubs_alert.namespace_postgres_connector_primary_key
    GDI_NAMESPACE                   = module.eventhubs_alert.namespace_fqn
    GDI_DB_HOST                     = module.grafana.datasci_fqdn
    GDI_DB_USER                     = format("%s@%s", module.grafana.datasci_login, module.grafana.datasci_server_name)
    GDI_DB_PASSWORD                 = module.grafana.datasci_password
    GDI_CHECKPOINT_STORE_CONNECTION = module.grafana.gfi_storage_account_connection_string
    GDI_CHECKPOINT_STORE_CONTAINER  = module.grafana.gfi_storage_container_name
  }

  type = "Opaque"
}

resource "kubernetes_secret" "grafana-env-vars" {
  metadata {
    name      = "grafana-env-vars"
    namespace = kubernetes_namespace.pipeline.metadata[0].name
  }

  data = {
    CONSUL_HTTP_ADDR                = "consul-server:8500"
    DS_DATABASE_HOST                = module.grafana.datasci_fqdn
    DS_DATABASE_NAME                = "grafana"
    DS_DATABASE_USER                = format("%s@%s", module.grafana.datasci_login, module.grafana.datasci_server_name)
    DS_DATABASE_PASSWORD            = module.grafana.datasci_password
    DS_DATABASE_TYPE                = "postgres"
    DS_PROMETHEUS_HOST              = "pipeline-prometheus-server"
    GF_DATABASE_HOST                = module.grafana.datasci_fqdn
    GF_DATABASE_NAME                = "grafanaconfig"
    GF_DATABASE_USER                = format("%s@%s", module.grafana.datasci_login, module.grafana.datasci_server_name)
    GF_DATABASE_PASSWORD            = module.grafana.datasci_password
    GF_DATABASE_TYPE                = "postgres"
    GF_DATABASE_SSL_MODE            = "require"
    GF_DATABASE_CONN_MAX_LIFETIME   = 14400
    GF_DATABASE_MAX_IDLE_CONN       = 2
    GF_DATABASE_MAX_OPEN_CONN       = 0
  }

  type = "Opaque"
}

# Secrets used in Elasticsearch namespace
resource "kubernetes_secret" "elasticsearch-mqtt-eventhub-creds" {
  metadata {
    name      = "mqtt-eventhub-creds"
    namespace = kubernetes_namespace.elasticsearch.metadata[0].name
  }

  data = {
    connection-string = module.eventhubs_mqtt.namespace_connection_string
  }

  type = "Opaque"
}

resource "kubernetes_secret" "elasticsearch-alerts-eventhub-creds" {
  metadata {
    name      = "alerts-eventhub-creds"
    namespace = kubernetes_namespace.elasticsearch.metadata[0].name
  }

  data = {
    connection-string = module.eventhubs_alert.namespace_connection_string
  }

  type = "Opaque"
}

resource "kubernetes_secret" "elasticsearch-photo-eventhub-creds" {
  metadata {
    name      = "photos-eventhub-creds"
    namespace = kubernetes_namespace.elasticsearch.metadata[0].name
  }

  data = {
    connection-string = module.eventhubs_events.namespace_connection_string
  }

  type = "Opaque"
}


#
# Manifests
#
# Flux manifests
resource "kubectl_manifest" "install" {
  for_each   = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}

resource "kubectl_manifest" "sync" {
  for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}