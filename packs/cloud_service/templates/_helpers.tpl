// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .cloud_service.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .cloud_service.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .cloud_service.region "") -]]
region = [[ .cloud_service.region | quote]]
[[- end -]]
[[- end -]]
