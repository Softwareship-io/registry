You deployed a service to Nomad.

There are [[ .cloud_service.count ]] instances of your job now running.

The service is using the image: [[.cloud_service.image | quote]]

[[ if .cloud_service.register_consul_service ]]
You registered an associated Consul service named [[ .cloud_service.consul_service_name ]].

[[ if .cloud_service.has_health_check ]]
This service has a health check at the path : [[ .cloud_service.health_check.path | quote ]]
[[ end ]]
[[ end ]]

