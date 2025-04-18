resource "octopusdeploy_github_repository_feed" "github" {
  name = "GitHub Feed TF"  
  feed_uri = "https://api.github.com"
}

resource "octopusdeploy_nuget_feed" "feedz" {
  name = "Feedz Feed TF"  
  feed_uri = "https://f.feedz.io/octopus-deploy-samples/octopus-samples/nuget/index.json"
}

resource "octopusdeploy_docker_container_registry" "docker" {
  name = "Docker Feed TF"
  feed_uri = "https://index.docker.io"
  username = var.octopus_feed_dockerhub_username
  password = var.octopus_feed_dockerhub_password
}

resource "octopusdeploy_docker_container_registry" "ghcr" {
  name = "GitHub Container Registry Feed TF"
  feed_uri = "https://ghcr.io"
  username = var.octopus_feed_ghcr_username
  password = var.octopus_feed_ghcr_password
}