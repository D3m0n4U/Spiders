#!/bin/bash

# Function to crawl a webpage and extract links
function crawl_page() {
    local url="$1"
    local depth="$2"
    local indent="$3"

    # Download the webpage
    wget -q -O "$depth.html" "$url"

    # Extract links from the webpage
    grep -o '<a [^>]*href=["'"'"'][^"'"'"']*["'"'"']' "$depth.html" | 
    sed -e 's/^<a [^>]*href=["'"'"']//' -e 's/["'"'"']$//' | 
    grep '^http' | 
    while read -r link; do
        echo "$indent$link" >> "$sitemap"  # Append the link to the sitemap file
        if [ "$depth" -lt "$MAX_DEPTH" ]; then
            crawl_page "$link" $((depth + 1)) "$indent  "
        fi
    done
}

# Main function
function main() {
    local input_file="$1"
    MAX_DEPTH=3  # Maximum depth to crawl

    # Create sitemap file
    sitemap="sitemap.txt"
    touch "$sitemap"

    # Crawl each URL in the list
    while IFS= read -r url; do
        crawl_page "$url" 0 ""
    done < "$input_file"

    # Remove temporary files
    rm *.html
}

# Check if the script is run with a file argument
if [ $# -eq 1 ]; then
    main "$1"
else
    echo "Usage: $0 <URLs_file>"
    exit 1
fi
