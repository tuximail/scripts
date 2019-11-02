#!/bin/bash

[ -z "$1" ] && echo "please pass the path of your html files as first argument" && exit 1

cd "$1"

posts=$(cat index.html | grep -i "<li>" | sed 's/.*">//' | sed 's/<.*//')

echo "<?xml version='1.0' encoding='utf-8'?>
<rss version='2.0'>
<channel>
<title>Tuximail</title>
<description>A Linux Blog with irregular updates</description>
<link>https://tuximail.github.io</link>
<language>en-us</language>
<pubDate>$(date "+%a, %d %b %Y %H:%M:%S %Z")</pubDate>" > tuximail.rss


while read -r title; do
	line=$(cat index.html | grep "$title")
	date=$(echo "$line" | sed 's/<li>//' | sed 's/-.*//')
	url=$(echo "$line" | sed 's/.*="//' | sed 's/">.*//')
	content=$(cat "$url")
	echo "<item>
		<title>${title}</title>
		<description><![CDATA[${content}]]></description>
		<link>https://tuximail.github.io/${url}</link>
		<guid isPermalink='false'>${url}</guid>
		<pubDate>${date}</pubDate>
	</item>" >> tuximail.rss


done <<< "$posts"

echo "</channel>
</rss>" >> tuximail.rss

