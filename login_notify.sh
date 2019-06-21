#!/bin/sh

# Change these two lines:
sender="name@domain.com"
recepient="name@domain.com"

logininfo="$(tail /var/log/auth.log | grep -i 'accepted password')"

if [ "$PAM_TYPE" != "close_session" ]; then
        host="`hostname`"
        subject="New SSH Login on $host"
        # Message sends last registrated login
        message="$logininfo"
    echo "$message" | mailx -r "$sender" -s "$subject" "$recepient"
fi

