job [[ template "job_name" . ]] {
[[ template "region" . ]]
datacenters = [[ .cloud_service.datacenters | toStringList ]]
type        = "service"

update {
  max_parallel     = 2
  min_healthy_time = "5s"
  healthy_deadline = "120s"
  auto_revert      = true
  auto_promote     = true
  canary           = 1
}

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
  canary_tags = [ "green" ]
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
  interval = "10m"
  delay    = "15s"
  mode     = [[ .cloud_service.restart_mode| quote ]]
}

task "server" {
  driver = "docker"

  config {
    image = [[.cloud_service.image | quote]]
  }

  [[- $env_vars_length := len .cloud_service.env_vars ]]
  [[- if not (eq $env_vars_length 0) ]]
  env {
    [[- range $var := .cloud_service.env_vars ]]
    [[ $var.key ]] = [[ $var.value ]]
    [[- end ]]
  }
  [[- end ]]


  resources {
    cpu    = [[ .cloud_service.resources.cpu ]]
    memory = [[ .cloud_service.resources.memory ]]
  }
}
}
}
