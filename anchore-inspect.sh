#!/bin/bash
set -e

usage() {
cat << EOF
Analyze a Helm charts container images

Your Anchore CLI credentials should be set as environment variables: https://github.com/anchore/anchore-cli

Available Commands:
    helm anchore inspect --chart [Chart name]           Analyze a Helm charts container images

    helm anchore evaluate --chart [Chart name]          Evaluate a previously analzyed Helm charts container images against an Anchore policy

    helm anchore delete --chart [Chart name]            Delete all images discovered in a previously analyzed Helm chart from Anchore

Available Flags:
    --chart          (Required) Specify the Helm chart to analyze

Example Usage:
    helm anchore inspect --chart stable/wordpress

    helm anchore evaluate --chart stable/wordpress

    helm anchore delete --chart stable/wordpress
EOF
}

# Create passthru array
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
    --json)
    JSON=TRUE
    shift # past argument
    shift # past value
    ;;
    --help)
    HELP=TRUE
    shift # past argument
    ;;
    *)    # unknown option
    PASSTHRU+=("$1") # save it 
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

## Inspect will search through Helm chart and add all found container images to Anchore for analysis
if [ "$COMMAND" == "inspect" ]; then
    echo "Inspecting Helm chart: $CHART"
    IMAGES=( $(helm install --generate-name "$CHART" --dry-run | grep image: | sed 's/ //g' | cut -c 7- | tr -d '"'))
    for image in "${IMAGES[@]}"
    do 
        echo "Analyzing:" "${image}"
        if [ "$JSON" == "TRUE" ] then
            anchore-cli --json image add "${image}"
        else
            anchore-cli image add "${image}"
    done
    exit 0
## Get a list of vulnerabilities for all container images in Helm chart
## NOTE: The 'inspect' command should be run first to add images to the Anchore system    
elif [ "$COMMAND" == "vuln" ]; then
    echo "Getting vulnerabilities for Helm chart: $CHART"
    IMAGES=( $(helm install --generate-name "$CHART" --dry-run | grep image: | sed 's/ //g' | cut -c 7- | tr -d '"'))
    for image in "${IMAGES[@]}"
    do 
        echo "Getting vulnerabilities for: ${image}"
        if [ "$JSON" == "TRUE" ] then
            anchore-cli --json image vuln "${image}" all || true
        else
            anchore-cli image vuln "${image}" all || true
    done
    exit 0  
## Evaluate all container images in Helm chart against current Anchore policy bundle
## NOTE: The 'inspect' command should be run first to add images to the Anchore system    
elif [ "$COMMAND" == "evaluate" ]; then
    echo "Evaluating Helm chart: $CHART"
    IMAGES=( $(helm install --generate-name "$CHART" --dry-run | grep image: | sed 's/ //g' | cut -c 7- | tr -d '"'))
    for image in "${IMAGES[@]}"
    do 
        echo "Evaluating: ${image}"
        anchore-cli evaluate check "${image}" || true
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