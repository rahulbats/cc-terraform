#Confluent CLoud Keys used to create the cluster
confluent_cloud_api_key="4EPG324I2RTHUXDJ"
confluent_cloud_api_secret = "KEJN7ZaT+leWKKojJPDmzq1DnsLJvRjmIqkJtVz8lyA68G4KarrPmsRL9nVRS6Qw"

#CLuster Environment details
confluent_cloud_env_name="rahul-env"

# Cluster details
confluent_cloud_cluster_display_name="Mckesson_NonProd"
confluent_cloud_cluster_cloud="AZURE"
confluent_cloud_cluster_availability="MULTI_ZONE"
confluent_cloud_cluster_region="westus2"
confluent_cloud_cluster_cku=2
confluent_cloud_cluster_type="standard"


admin_sa_name="mck_admin_sa"


confluent_cloud_env_id="env-kg2knp"

consumer_sa_name="mck_consumer_sa"
producer_sa_name="mck_producer_sa"

topics = [
   {
    name: "platform-topic-a",
    partitions: 1
  },
  {
    name: "platform-topic-2",
    partitions: 2
  }
]

