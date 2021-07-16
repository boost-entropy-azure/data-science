terraform {
  required_providers {
    databricks = {
      source  = "databrickslabs/databricks"
      version = "0.3.5"
    }
  }
}

provider "databricks" {
  azure_workspace_resource_id = var.workspace_id
}

resource "databricks_secret_scope" "analytics" {
  name = "analytics-secrets-scope"
}

data "databricks_spark_version" "latest" {}
data "databricks_node_type" "smallest" {
  local_disk = true
}

resource "databricks_cluster" "analytics" {
  cluster_name            = join("-", [var.cluster_name, var.environment, "cluster"])
  spark_version           = data.databricks_spark_version.latest.id
  instance_pool_id        = databricks_instance_pool.smallest_nodes.id
  autotermination_minutes = 20
  autoscale {
    min_workers = 1
    max_workers = 10
  }
}

resource "databricks_instance_pool" "smallest_nodes" {
  instance_pool_name = join("-", [var.cluster_name, var.environment, "instance-pool"])
  min_idle_instances = 0
  max_capacity       = 30
  node_type_id       = data.databricks_node_type.smallest.id
  preloaded_spark_versions = [
    data.databricks_spark_version.latest.id
  ]

  idle_instance_autotermination_minutes = 20
}

resource "databricks_cluster_policy" "analytics" {
  name = join("-", [var.cluster_name, var.environment, "cluster-policy"])
  definition = jsonencode({
    "dbus_per_hour" : {
      "type" : "range",
      "maxValue" : 10
    },
    "autotermination_minutes" : {
      "type" : "fixed",
      "value" : 20,
      "hidden" : true
    }
  })
}

resource "databricks_job" "analytics" {
  name = "gnss-monitor"

  new_cluster {
    num_workers   = 1
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
  }

  email_notifications {}
}