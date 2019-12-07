# Anchore Helm Plugin

Helm plugin for Anchore to analyze a Helm charts container images

## Installation

Install the plugin using the built-in helm plugin command:

`helm plugin install --version 0.1.0 https://github.com/valancej/helm-anchore.git`

This plugin is utilized the [Anchore CLI](https://github.com/anchore/anchore-cli) to connect to a running Anchore Engine instance.

Your Anchore CLI credentials should be set as environment variables:

```
ANCHORE_CLI_URL=http://myserver.example.com:8228/v1
ANCHORE_CLI_USER=admin
ANCHORE_CLI_PASS=foobar
```

### Available Commands:
Analyze a Helm charts container images

`helm anchore inspect --chart [Chart Name]`

Remove a previously inspect Helm charts analyzed container images from Anchore

`helm anchore delete --chart [Chart Name]`

### Available Flags:
`--chart`          (Required) Specify the Helm chart to analyze

### Usage
Example Usage:
`helm anchore inspect --chart stable/wordpress`

`helm anchore delete --chart stable/wordpress`