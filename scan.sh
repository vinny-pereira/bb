#!/bin/bash

DOMAIN_FILE="domains.txt"
SUBLIST3R_OUT="sublist3r.txt"
SUB_DOMAIN_FILE="subdomains.txt"
LIVE_SERVERS_OUT="liveservers.txt"
HTTP_RESP_OUT="http_responses.txt"

touch $SUB_DOMAIN_FILE
touch $SUBLIST3R_OUT

subfinder -dL "$DOMAIN_FILE" -o "$SUB_DOMAIN_FILE" -v

while IFS= read -r line; do
    sublist3r.py -d "$line" -o "$SUBLIST3R_OUT"
    cat "$SUBLIST3R_OUT" | anew "$SUB_DOMAIN_FILE"
done < "$DOMAIN_FILE"

rm $"SUBLIST3R_OUT"

touch $LIVE_SERVERS_OUT

httpx -l "$SUB_DOMAIN_FILE" -o "$LIVE_SERVERS_OUT"

cat $LIVE_SERVERS_OUT | fff -d 500 -b -S -o "$HTTP_RESP_OUT"

mkdir gobuster

while IFS= read -r line; do
  gobuster dir -e -u "$line" -w /opt/SecLists/Discovery/Web-Content/common.txt -o ./gobuster/$subdomain-gobuster-results.txt
done < subdomains.txt
