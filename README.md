# Anchore Helm Plugin

Helm plugin for Anchore to analyze a Helm charts container images

## Installation

Install the plugin using the built-in helm plugin command:

`helm plugin install https://github.com/valancej/helm-anchore`

This plugin utilizes the [Anchore CLI](https://github.com/anchore/anchore-cli) to connect to a running Anchore Engine instance.

Your Anchore CLI credentials should be set as environment variables:

```
ANCHORE_CLI_URL=http://myserver.example.com:8228/v1
ANCHORE_CLI_USER=admin
ANCHORE_CLI_PASS=foobar
```

### Available Commands:
Analyze a Helm charts container images

`helm anchore inspect --chart [Chart Name]`

Remove a previously inspected Helm charts analyzed container images from Anchore

`helm anchore delete --chart [Chart Name]`

### Available Flags:
`--chart`          (Required) Specify the Helm chart to analyze

### Usage
Example Usage:

`helm anchore inspect --chart stable/wordpress`

`helm anchore delete --chart stable/wordpress`
