job [[ template "job_name" . ]] {
[[ template "region" . ]]
datacenters = [[ .my.datacenters | toStringList ]]
type        = "service"

group "postgres" {
  count = [[ .my.app_count ]]

  network {
    mode = [[ .my.network.mode | quote ]]
    [[- range $port := .my.network.ports ]]
    port [[ $port.name | quote ]] {
    to = [[ $port.port ]]
  }
  [[- end ]]
}

update {
  min_healthy_time  = [[ .my.update.min_healthy_time | quote ]]
  healthy_deadline  = [[ .my.update.healthy_deadline | quote ]]
  progress_deadline = [[ .my.update.progress_deadline | quote ]]
  auto_revert       = [[ .my.update.auto_revert ]]
}

service {
  name = [[ .my.consul_service_name | quote ]]
  port = [[ .my.consul_service_port | quote ]]
  tags = [ [[ range $idx, $tag := .my.consul_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]
  canary_tags = [ "canary" ]

   [[- if .my.upstreams ]]
  connect {
    sidecar_service {
      proxy {
        [[- range $upstream := .my.upstreams ]]
        upstreams {
          destination_name = [[ $upstream.name | quote ]]
          local_bind_port  = [[ $upstream.port ]]
        }
        [[- end ]]
      }
    }
  }
  [[- end ]]
  }

  restart {
    attempts = [[ .my.restart_attempts ]]
    interval = "30m"
    delay    = "15s"
    mode     = "fail"
  }

  task "postgres" {
    driver = "docker"
    config {
      image = [[.my.image | quote]]
      volumes = [
        "[[.my.volume_path]]:/srv/postgres/data/pgdata",
      ]
      entrypoint = ["/bin/sh", "-c"]
      args = [
      "mkdir -p /srv/postgres/data/pgdata && exec docker-entrypoint.sh postgres"
      ]
    }

    [[- $postgresql_task_env_vars_length := len .my.env_vars ]]
    [[- if not (eq $postgresql_task_env_vars_length 0) ]]
    env {
      [[- range $var := .my.env_vars ]]
      [[ $var.key ]] = [[ $var.value | quote ]]
      [[- end ]]
    }
    [[- end ]]

    resources {
      cpu    = [[ .my.resources.cpu ]]
      memory = [[ .my.resources.memory ]]
    }
  }
}
}