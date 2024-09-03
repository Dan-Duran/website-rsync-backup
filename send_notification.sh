#!/bin/bash

# Configuration
SMTP_SERVER="smtp.example.com"
SMTP_PORT="587"
SMTP_USER="your_email@example.com"
SMTP_PASS="your_email_password"
FROM_EMAIL="your_email@example.com"
TO_EMAIL="admin@example.com"

# Function to send email
send_email() {
    local subject="$1"
    local body="$2"
    local attachment="$3"
    local priority="$4"

    local priority_flag=""
    if [ "$priority" = "high" ]; then
        priority_flag="-e 'my_hdr X-Priority: 1'"
    fi

    if [ -n "$attachment" ] && [ -f "$attachment" ]; then
        mutt -s "$subject" -e "set content_type=text/html" \
             -e "set from=$FROM_EMAIL" \
             -e "set smtp_url=smtp://$SMTP_USER:$SMTP_PASS@$SMTP_SERVER:$SMTP_PORT" \
             -e "set ssl_starttls=yes" \
             -e "set ssl_force_tls=yes" \
             $priority_flag \
             -a "$attachment" -- "$TO_EMAIL" <<EOF
$body
EOF
    else
        echo "$body" | mutt -s "$subject" -e "set content_type=text/html" \
             -e "set from=$FROM_EMAIL" \
             -e "set smtp_url=smtp://$SMTP_USER:$SMTP_PASS@$SMTP_SERVER:$SMTP_PORT" \
             -e "set ssl_starttls=yes" \
             -e "set ssl_force_tls=yes" \
             $priority_flag \
             -- "$TO_EMAIL"
    fi

    if [ $? -eq 0 ]; then
        echo "Email sent successfully"
    else
        echo "Failed to send email"
    fi
}

# Main execution
if [ $# -lt 3 ]; then
    echo "Usage: $0 <subject> <body> <is_failure> [attachment]"
    exit 1
fi

subject="$1"
body="$2"
is_failure="$3"
attachment="$4"

# Set email priority based on failure status
priority="normal"
if [ "$is_failure" = "true" ]; then
    priority="high"
fi

send_email "$subject" "$body" "$attachment" "$priority"
