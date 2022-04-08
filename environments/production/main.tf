terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

provider "docker" {
  host = "tcp://10.0.1.201:2375/"
}

resource "docker_network" "runner" {
  name = "runner"
  driver = "bridge"
}

resource "docker_image" "runner" {
  name         = "gitlab/gitlab-runner:latest"
  keep_locally = false
}

resource "docker_volume" "gitlab-runner-config" {
  name = "gitlab-runner-config"
}

resource "docker_container" "runner" {
  image = docker_image.runner.latest
  name = "runner"
  hostname = "runner"
  remove_volumes = false
  restart = "always"
  networks_advanced {
    name = "runner"
  }
  volumes {
        volume_name = "gitlab-runner-config"
        container_path = "/etc/gitlab-runner"
  }
  volumes {
        host_path = "/var/run/docker.sock"
        container_path = "/var/run/docker.sock"
  }
}

resource "docker_image" "mysql" {
  name         = "mysql:5.7"
  keep_locally = false
}

resource "docker_volume" "mysql_volume" {
  name = "mysql_volume"
}

resource "docker_container" "mysql" {
  image = docker_image.mysql.latest
  name = "db"
  hostname = "db"
  env = ["MYSQL_ROOT_PASSWORD=root", "MYSQL_DATABASE=dev_db", "MYSQL_USER=nsa", "MYSQL_PASSWORD=nsa"]
  remove_volumes = false
  restart = "always"
  volumes {
        volume_name = "mysql_volume"
        container_path = "/var/lib/mysql"
  }
  ports {
    internal = 3306
        external = 3306
  }
}

data "docker_registry_image" "frontend" {
  name = "winterex/cm_frontend:latest"
}

resource "docker_image" "frontend" {
  name          = data.docker_registry_image.frontend.name
  pull_triggers = [data.docker_registry_image.frontend.sha256_digest]
  keep_locally = false
}

resource "docker_container" "frontend" {
  image = docker_image.frontend.latest
  name = "frontend"
  hostname = "frontend"
  restart = "always"
  env = ["REACT_APP_API_URL=api.epitech.h.metrone.fr"]
  ports {
    internal = 3000
    external = 80
  }
}

resource "docker_container" "frontend2" {
  image = docker_image.frontend.latest
  name = "frontend2"
  hostname = "frontend2"
  restart = "always"
  env = ["REACT_APP_API_URL=api.epitech.h.metrone.fr"]
  ports {
    internal = 3000
    external = 81
  }
}

data "docker_registry_image" "backend" {
  name = "winterex/cm_backend:latest"
}

resource "docker_image" "backend" {
  name          = data.docker_registry_image.backend.name
  pull_triggers = [data.docker_registry_image.backend.sha256_digest]
  keep_locally = false
}

resource "docker_container" "backend" {
  image = docker_image.backend.latest
  name = "backend"
  hostname = "backend"
  restart = "always"
  env = ["DB_HOST=10.0.1.201"]
  ports {
    internal = 3000
    external = 3000
  }
  depends_on = [docker_container.mysql]
}

resource "docker_container" "backend2" {
  image = docker_image.backend.latest
  name = "backend2"
  hostname = "backend2"
  restart = "always"
  env = ["DB_HOST=10.0.1.201"]
  ports {
    internal = 3000
    external = 3001
  }
  depends_on = [docker_container.mysql]
}

