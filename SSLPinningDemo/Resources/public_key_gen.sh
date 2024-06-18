#!/bin/sh

#  public_key_gen.sh
#  SSLPinningDemo
#
#  Created by Krunal Patel on 18/06/24.
#  

# Check if the user provided a website URL
if [ -z "$1" ]; then
    echo "Usage: $0 <website>"
    exit 1
fi

# Get the website URL from the command line argument
website="$1"

# Extract the public key from the website using OpenSSL
public_key=$(openssl s_client -connect "$website":443 </dev/null 2>/dev/null | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64)

# Check if the public key extraction was successful
if [ -z "$public_key" ]; then
    echo "Failed to extract public key from $website"
    exit 1
fi

# Output the public key
echo "Public Key for $website:"
echo "$public_key"

header=$(echo -n "$public_key" | hexdump -n 24 -e '24/1 "0x%02x, "')
# Output the ASN.1 header
echo "ASN.1 Header for $website:"
echo "$header"
