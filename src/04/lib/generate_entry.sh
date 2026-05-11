#!/bin/bash

# Arrays of generation data

RESPONSE_CODES=(200 201 400 401 403 404 500 501 502 503)

METHODS=(GET POST PUT PATCH DELETE)

URLS=(
    "/index.html"
    "/about"
    "/contact"
    "/api/v1/users"
    "/api/v1/products"
    "/api/v1/orders"
    "/api/v2/auth/login"
    "/api/v2/auth/logout"
    "/static/css/main.css"
    "/static/js/app.js"
    "/images/logo.png"
    "/favicon.ico"
    "/robots.txt"
    "/sitemap.xml"
    "/admin/dashboard"
    "/admin/users"
    "/search?q=nginx"
    "/search?q=linux"
    "/download/report.pdf"
    "/upload"
)

# User-Agent templates
# Format: "Browser_label|User-Agent string"
USER_AGENTS=(
    "Mozilla|Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0"
    "Chrome|Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Opera|Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 OPR/106.0.0.0"
    "Safari|Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
    "MSIE|Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)"
    "Edge|Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0"
    "Crawler|Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
    "LibTool|curl/7.88.1"
)

# Generate a random element from an array
random_element() {
    local -n _arr=$1
    echo "${_arr[$(( RANDOM % ${#_arr[@]} ))]}"
}

# Generate a random request size in bytes (100 - 50000)
generate_body_size() {
    echo $(( RANDOM % 49901 + 100 ))
}

# Generate a random referer
generate_referer() {
    local referers=(
        "-"
        "https://www.google.com/"
        "https://www.bing.com/"
        "https://duckduckgo.com/"
        "https://example.com/page"
        "-"
        "-"
    )
    random_element referers
}

# Generate one nginx combined log entry
# Args: log_date (YYYY-MM-DD), timestamp_seconds
generate_entry() {
    local log_date="$1"
    local ts="$2"

    local ip
    ip=$(generate_ip)

    local datetime
    datetime=$(date -d "@$ts" '+%d/%b/%Y:%H:%M:%S %z')

    local method
    method=$(random_element METHODS)

    local url
    url=$(random_element URLS)

    local code
    code=$(random_element RESPONSE_CODES)

    local size
    size=$(generate_body_size)

    local referer
    referer=$(generate_referer)

    local agent_entry
    agent_entry=$(random_element USER_AGENTS)
    local agent="${agent_entry#*|}"

    # nginx combined format:
    # $remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"
    printf '%s - - [%s] "%s %s HTTP/1.1" %s %s "%s" "%s"\n' \
        "$ip" "$datetime" "$method" "$url" "$code" "$size" "$referer" "$agent"
}