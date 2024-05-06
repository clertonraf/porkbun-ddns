#!/bin/bash

# Read configuration from config.conf
if [ -f "config.conf" ]; then
    source "config.conf"
else
    echo "Config file not found."
    exit 1
fi

porkbun_ping="https://porkbun.com/api/json/v3/ping"
porkbun_domain_list="https://porkbun.com/api/json/v3/dns/retrieve/$domain"

# Function to handle API calls
call_api() {
    endpoint="$1"
    data="$2"

    curl_output=$(curl -s -X POST -H "Content-Type: application/json" -d "$data" "$endpoint")
    echo "$curl_output"
}

# Ping porkbun
raw_ping=$(call_api "$porkbun_ping" "{\"secretapikey\": \"$secretapikey\", \"apikey\": \"$apikey\"}")

ping_status=$(jq -r '.status' <<< "$raw_ping")
if [ "$ping_status" != "SUCCESS" ]; then
    echo "Ping failed"
    exit 1
fi

myip=$(jq -r '.yourIp' <<< "$raw_ping")
echo "My public IP address is: $myip"

# Retrieve domain records
raw_domain_list=$(call_api "$porkbun_domain_list" "{\"secretapikey\": \"$secretapikey\", \"apikey\": \"$apikey\"}")

domain_list_status=$(jq -r '.status' <<< "$raw_domain_list")
if [ "$domain_list_status" != "SUCCESS" ]; then
    echo "Failed to get domain list"
    exit 1
fi

# Filter records to update
records=$(jq -c '.records | .[] | select(.type == "A" and .content != "'"$myip"'") | {id, name, type, content, ttl}' <<< "$raw_domain_list")

# Update DNS records
while IFS= read -r record; do
    record_id=$(jq -r '.id' <<< "$record")
    record_name=$(jq -r '.name' <<< "$record")
    record_type=$(jq -r '.type' <<< "$record")
    record_ttl=$(jq -r '.ttl' <<< "$record")

    echo "Updating record $record_id: $record_name $record_type $myip $record_ttl"

    raw_domain_update=$(call_api "https://porkbun.com/api/json/v3/dns/edit/$domain/$record_id" "{\"secretapikey\": \"$secretapikey\", \"apikey\": \"$apikey\", \"name\": \"$record_name\", \"type\": \"$record_type\", \"content\": \"$myip\", \"ttl\": \"$record_ttl\"}")

    domain_update_status=$(jq -r '.status' <<< "$raw_domain_update")
    if [ "$domain_update_status" != "SUCCESS" ]; then
        echo "Failed to update domain"
        exit 1
    fi
done <<< "$records"
