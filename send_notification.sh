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
    local priority="$3"
    local priority_flag=""
    if [ "$priority" = "high" ]; then
        priority_flag="-e 'my_hdr X-Priority: 1'"
    fi
    echo "$body" | mutt -s "$subject" -e "set content_type=text/html" \
         -e "set from=$FROM_EMAIL" \
         -e "set smtp_url=smtp://$SMTP_USER:$SMTP_PASS@$SMTP_SERVER:$SMTP_PORT" \
         -e "set ssl_starttls=yes" \
         -e "set ssl_force_tls=yes" \
         $priority_flag \
         -- "$TO_EMAIL"
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
    local priority="$3"
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
if [ $# -lt 2 ]; then
    echo "Usage: $0 <is_failure> <SITE>"
    exit 1
fi

is_failure="$1"
SITE="$2"

if [ "$is_failure" = "true" ]; then
    subject="Backup for $SITE failed"
    body="The backup process for $SITE failed. Please check the log file for details."
    priority="high"
else
    subject="Backup for $SITE successful"
    body="The backup process for $SITE has completed successfully. Please check the log file for details."
    priority="normal"
fi

# Send email based on configured method
if [ "$EMAIL_METHOD" = "smtp" ]; then
    send_email_smtp "$subject" "$body" "$priority"
elif [ "$EMAIL_METHOD" = "postmark" ]; then
    send_email_postmark "$subject" "$body" "$priority"
else
    echo "Invalid EMAIL_METHOD. Please set it to either 'smtp' or 'postmark'."
    exit 1
fi
