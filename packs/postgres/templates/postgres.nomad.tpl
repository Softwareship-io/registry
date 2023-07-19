job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .my.datacenters | toStringList ]]
  type        = "service"

  group "postgres" {
  count = [[ .my.app_count ]]

  network {
    mode = "bridge"
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

      connect {
        sidecar_service {}
      }
    }

    restart {
      attempts = [[ .my.restart_attempts ]]
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    task "postgres" {
      driver = "docker"
      user   = 1001

      config {
        image = [[.my.image | quote]]
        volumes = [
          "[[.my.volume_path]]:/bitnami/postgresql",
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

    task "create-postgresql-data-folder" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "raw_exec"

      config {
        command = "sh"
        args    = ["-c", "mkdir -p [[.my.volume_path]] && chown 1001:1001 [[.my.volume_path]]"]
      }

      resources {
        cpu    = [[ .my.data_folder_task_resources.cpu ]]
        memory = [[ .my.data_folder_task_resources.memory ]]
      }
    }
  }
}