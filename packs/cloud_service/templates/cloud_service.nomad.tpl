job [[ template "job_name" . ]] {
[[ template "region" . ]]
datacenters = [[ .cloud_service.datacenters | toStringList ]]
type        = "service"

group "app" {
  count = [[ .cloud_service.count ]]

  network {
    mode = "bridge"
    [[- range $port := .cloud_service.ports ]]
    port [[ $port.name | quote ]] {
    to = [[ $port.port ]]
  }
  [[- end ]]
}

[[- if .cloud_service.register_consul_service ]]
service {
  name = "[[ .cloud_service.consul_service_name ]]"
  port = "[[ .cloud_service.consul_service_port ]]"
  tags = [[ .cloud_service.consul_tags | toStringList ]]
  [[- if .cloud_service.upstreams ]]
  connect {
    sidecar_service {
      proxy {
        [[- range $upstream := .cloud_service.upstreams ]]
        upstreams {
          destination_name = [[ $upstream.name | quote ]]
          local_bind_port  = [[ $upstream.port ]]
        }
        [[- end ]]
      }
    }
  }
  [[- end ]]

  check {
    name     = "alive"
    type     = "http"
    path     = [[ .cloud_service.health_check.path | quote ]]
    interval = [[ .cloud_service.health_check.interval | quote ]]
    timeout  = [[ .cloud_service.health_check.timeout | quote ]]
  }
}
[[- end ]]

restart {
  attempts = [[ .cloud_service.restart_attempts ]]
  interval = "30m"
  delay    = "15s"
  mode     = "fail"
}

task "server" {
  driver = "docker"

  config {
    image = [[.cloud_service.image | quote]]
    ports = ["http"]
  }

env {
  [[- range $key, $value := .cloud_service.env_vars ]]
  [[ $key ]] = [[ $value | quote ]]
  [[- end ]]
}





  resources {
    cpu    = [[ .cloud_service.resources.cpu ]]
    memory = [[ .cloud_service.resources.memory ]]
  }
}
}
}
