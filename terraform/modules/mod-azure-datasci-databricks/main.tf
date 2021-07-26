terraform {
  required_providers {
    databricks = {
      source  = "databrickslabs/databricks"
      version = "0.3.6"
    }
  }
}

provider "databricks" {
  host                        = var.databricks_host
  azure_workspace_resource_id = var.workspace_id
  azure_client_id             = var.client_id
  azure_client_secret         = var.client_secret
  azure_tenant_id             = var.tenant_id
}

resource "databricks_secret_scope" "analytics" {
  name = "analytics-secrets-scope"
  initial_manage_principal = "users"
}

data "databricks_spark_version" "latest" {}
data "databricks_node_type" "smallest" {
  local_disk = true
}

//resource "databricks_dbfs_file" "datasci_library" {
//  source = "/home/vagrant/sandbox/datasci-message-monitor/build/libs/datasci-message-monitor-0.5.0.jar"
//  path   = "/FileStore/tables/datasci_message_monitor_0_5_0.jar"
//}
//
//resource "databricks_dbfs_file" "job_library" {
//  source = "/home/vagrant/sandbox/gnss-monitor/build/libs/gnss-monitor-0.1.1_SNAPSHOT.jar"
//  path   = "/FileStore/tables/gnss_monitor_0_1_1_SNAPSHOT.jar"
//}

resource "databricks_job" "analytics" {
  name           = "gnss-monitor"
  always_running = true

  spark_submit_task {
    parameters = [
      "--class","com.chesapeaketechnology.datasci.gnssmonitor.GnssMonitor",
      "--jars","dbfs:/FileStore/tables/datasci_message_monitor_0_5_0.jar","dbfs:/FileStore/tables/gnss_monitor_0_1_1_SNAPSHOT.jar"]
  }

//  library {
//    jar = databricks_dbfs_file.datasci_library.dbfs_path
//  }
//
//  library {
//    jar = databricks_dbfs_file.job_library.dbfs_path
//  }

  new_cluster {
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
    autoscale {
      min_workers = 1
      max_workers = 8
    }

    spark_env_vars = {
      GNSS_MONITOR_REDIS_HOST: var.redis_host,
      GNSS_MONITOR_REDIS_PORT: var.redis_port,
      GNSS_MONITOR_REDIS_SECRET: var.redis_secret

      GNSS_MONITOR_AZURE_CLIENT_ID: var.client_id
      GNSS_MONITOR_AZURE_TENANT_ID: var.tenant_id
      GNSS_MONITOR_AZURE_SECRET: var.client_secret
      GNSS_MONITOR_AZURE_EH_SOURCE_CONNECTION: var.azure_source_connection_string
      GNSS_MONITOR_AZURE_EH_SINK_CONNECTION: var.azure_sink_connection_string
      GNSS_MONITOR_AZURE_DATALAKE_NAME: var.azure_datalake_name
      GNSS_MONITOR_AZURE_DATALAKE_ENDPOINT: var.azure_datalake_endpoint
    }
  }

}