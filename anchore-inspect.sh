#!/bin/bash
set -e

usage() {
cat << EOF
Analyze a Helm charts container images

Your Anchore CLI credentials should be set as environment variables: https://github.com/anchore/anchore-cli

Available Commands:
    helm anchore inspect --chart [Chart Name]           Analyze a Helm charts container images

Available Flags:
    --chart          (Required) Specify the Helm chart to analyze

Example Usage:
    helm anchore inspect --chart stable/wordpress
EOF
}

# Create the passthru array
PASSTHRU=()
while [[ $# -gt 0 ]]
do
key="$1"

# Parse arguments
case $key in
    --chart)
    CHART="$2"
    shift # past argument
    shift # past value
    ;;
    --help)
    HELP=TRUE
    shift # past argument
    ;;
    *)    # unknown option
    PASSTHRU+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

# Restore PASSTHRU parameters
set -- "${PASSTHRU[@]}" 

# Show help if flagged
if [ "$HELP" == "TRUE" ]; then
    usage
    exit 0
fi

if [ -z "$CHART" ]; then
    echo "Error: No Chart provided. Please provide --chart flag"
    usage
    exit 1
fi 

COMMAND=${PASSTHRU[0]}

## Inspect will search through Helm chart and add all container images to Anchore for analysis
if [ "$COMMAND" == "inspect" ]; then
    echo "Inspecting Helm chart: $CHART"
    IMAGES=( $(helm install --generate-name "$CHART" --dry-run | grep image: | sed 's/ //g' | cut -c 7- | tr -d '"'))
    for image in "${IMAGES[@]}"
    do 
        echo "Analyzing:" "${image}"
        anchore-cli image add "${image}"
    done
    exit 0
## Delete will search through Helm chart and remove all container images from Anchore. Will use '--force' flag
elif [ "$COMMAND" == "delete" ]; then
    echo "Inspecting Helm chart: $CHART"
    IMAGES=( $(helm install --generate-name "$CHART" --dry-run | grep image: | sed 's/ //g' | cut -c 7- | tr -d '"'))
    for image in "${IMAGES[@]}"
    do 
        echo "Remove image:" "${image}"
        anchore-cli image del "${image}" --force || true
    done
    exit 0
else
    echo "Error: Invalid command, must be 'inspect' or 'delete'"
    usage
    exit 1
fi