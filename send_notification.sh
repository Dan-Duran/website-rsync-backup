#!/bin/bash

# Configuration
EMAIL_METHOD="smtp" # Set to "smtp" or "postmark"

# SMTP Configuration
SMTP_SERVER="smtp.example.com"
SMTP_PORT="587"
SMTP_USER="your_email@example.com"
SMTP_PASS="your_email_password"

# Postmark Configuration
POSTMARK_TOKEN="your-postmark-token-here"
POSTMARK_API_URL="https://api.postmarkapp.com/email"

# Common Configuration
FROM_EMAIL="your_email@example.com"
TO_EMAIL="admin@example.com"

# Function to send email via SMTP
send_email_smtp() {
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
        echo "Email sent successfully via SMTP"
    else
        echo "Failed to send email via SMTP"
    fi
}

# Function to send email via Postmark
send_email_postmark() {
    local subject="$1"
    local body="$2"
    local attachment="$3"
    local priority="$4"

    # Convert text body to HTML
    local html_body=$(echo "$body" | sed 's/$/<br>/')

    # Prepare JSON payload
    local json_payload=$(cat <<EOF
{
  "From": "$FROM_EMAIL",
  "To": "$TO_EMAIL",
  "Subject": "$subject",
  "HtmlBody": "$html_body",
  "MessageStream": "outbound"
}
EOF
)

    # Send request to Postmark API
    response=$(curl -s -X POST "$POSTMARK_API_URL" \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -H "X-Postmark-Server-Token: $POSTMARK_TOKEN" \
      -d "$json_payload")

    if echo "$response" | grep -q '"ErrorCode":0'; then
        echo "Email sent successfully via Postmark"
    else
        echo "Failed to send email via Postmark. Error: $response"
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

# Send email based on configured method
if [ "$EMAIL_METHOD" = "smtp" ]; then
    send_email_smtp "$subject" "$body" "$attachment" "$priority"
elif [ "$EMAIL_METHOD" = "postmark" ]; then
    send_email_postmark "$subject" "$body" "$attachment" "$priority"
else
    echo "Invalid EMAIL_METHOD. Please set it to either 'smtp' or 'postmark'."
    exit 1
fi
