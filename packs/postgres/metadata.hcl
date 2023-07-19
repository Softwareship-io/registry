# Copyright (c) softwareship, Inc.

app {
  url    = "https://github.com/postgres/postgres"
  author = "Postgres"
}

pack {
  name        = "postgres"
  description = "Postgres - Open-source, networked -- STANDALONE INSTANCE"
  url         = "https://github.com/Softwareship-io/registry/packs/postgres"
  version     = "0.0.1"
}

integration {
  identifier = "nomad/hashicorp/postgres"
  name       = "Postgres"
}