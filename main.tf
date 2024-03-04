# Confluent keys used
provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}




resource "confluent_kafka_cluster" "dedicated" {
  count = var.confluent_cloud_cluster_type=="dedicated" ? 1 : 0
  display_name = var.confluent_cloud_cluster_display_name
  availability = var.confluent_cloud_cluster_availability
  cloud        = var.confluent_cloud_cluster_cloud
  region       = var.confluent_cloud_cluster_region
  
  dedicated {
    cku = var.confluent_cloud_cluster_cku
  }

  environment {
    id = var.confluent_cloud_env_id
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "confluent_kafka_cluster" "standard"  {
  count = var.confluent_cloud_cluster_type=="standard" ? 1 : 0
  display_name = var.confluent_cloud_cluster_display_name
  availability = var.confluent_cloud_cluster_availability
  cloud        = var.confluent_cloud_cluster_cloud
  region       = var.confluent_cloud_cluster_region
  
  standard {}

  environment {
    id = var.confluent_cloud_env_id
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_service_account" "mckesson-admin-sa" {
  display_name = var.admin_sa_name
}



resource "confluent_service_account" "mckesson_producer_sa" {
  display_name = var.producer_sa_name
}

resource "confluent_service_account" "mckesson_consumer_sa" {
  display_name = var.consumer_sa_name
}


## Role binding for the Kafka cluster 
resource "confluent_role_binding" "mckesson-developer-manage" {
  principal   = "User:${confluent_service_account.mckesson-admin-sa.id}"
  role_name   = "DeveloperManage"
  crn_pattern = "${one(confluent_kafka_cluster.dedicated[*].rbac_crn)!=null?confluent_kafka_cluster.dedicated[0].rbac_crn:confluent_kafka_cluster.standard[0].rbac_crn}/kafka=${one(confluent_kafka_cluster.dedicated[*].id)!=null?confluent_kafka_cluster.dedicated[0].id:confluent_kafka_cluster.standard[0].id}/topic=platform*"
  depends_on = [
    confluent_service_account.mckesson-admin-sa
  ]
}



## Role binding for the Kafka cluster 
resource "confluent_role_binding" "mckesson-developer-read" {
  principal   = "User:${confluent_service_account.mckesson-consumer-sa.id}"
  role_name   = "DeveloperRead"
  crn_pattern = "${one(confluent_kafka_cluster.dedicated[*].rbac_crn)!=null?confluent_kafka_cluster.dedicated[0].rbac_crn:confluent_kafka_cluster.standard[0].rbac_crn}/kafka=${one(confluent_kafka_cluster.dedicated[*].id)!=null?confluent_kafka_cluster.dedicated[0].id:confluent_kafka_cluster.standard[0].id}/topic=platform*"
  depends_on = [
    confluent_service_account.mckesson-consumer-sa
  ]
}


## Role binding for the Kafka cluster 
resource "confluent_role_binding" "mckesson-developer-write" {
  principal   = "User:${confluent_service_account.mckesson-producer-sa.id}"
  role_name   = "DeveloperWrite"
  crn_pattern = "${one(confluent_kafka_cluster.dedicated[*].rbac_crn)!=null?confluent_kafka_cluster.dedicated[0].rbac_crn:confluent_kafka_cluster.standard[0].rbac_crn}/kafka=${one(confluent_kafka_cluster.dedicated[*].id)!=null?confluent_kafka_cluster.dedicated[0].id:confluent_kafka_cluster.standard[0].id}/topic=platform*"
  depends_on = [
    confluent_service_account.mckesson-producer-sa
  ]
}



resource "confluent_api_key" "mckesson-developer-manage-api-key" {
  display_name = "mckesson-admin-sa-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-manager' service account"
  owner {
    id          = confluent_service_account.mckesson-admin-sa.id
    api_version = confluent_service_account.mckesson-admin-sa.api_version
    kind        = confluent_service_account.mckesson-admin-sa.kind
  }

  managed_resource {
    id          = one(confluent_kafka_cluster.dedicated[*].id)!=null?confluent_kafka_cluster.dedicated[0].id:confluent_kafka_cluster.standard[0].id
    api_version = one(confluent_kafka_cluster.dedicated[*].api_version)!=null?confluent_kafka_cluster.dedicated[0].api_version:confluent_kafka_cluster.standard[0].api_version
    kind        = one(confluent_kafka_cluster.dedicated[*].kind)!=null?confluent_kafka_cluster.dedicated[0].kind:confluent_kafka_cluster.standard[0].kind

    environment {
      id = var.confluent_cloud_env_id
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}


module "topic" {
  for_each        = { for topic in var.topics : topic.name => topic }
  source          = "./topic"
  environment     = var.confluent_cloud_env_id
  cluster         = one(confluent_kafka_cluster.dedicated[*].id)!=null?confluent_kafka_cluster.dedicated[0].id:confluent_kafka_cluster.standard[0].id
  topic           = each.value
  
  admin_sa        = {
    id = confluent_api_key.mckesson-developer-manage-api-key.id
    secret = confluent_api_key.mckesson-developer-manage-api-key.secret
  }
  rbac_enabled    = var.rbac_enabled
  producer_sa_name = var.producer_sa_name
  consumer_sa_name = var.consumer_sa_name

  depends_on = [ confluent_service_account.mckesson_producer_sa , confluent_service_account.mckesson_consumer_sa ]

}





