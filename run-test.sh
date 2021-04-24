#!/bin/sh
set -e
sleep 5

test "$(curl -sfL http://darkhttpd/has-index)" = "It works" || false
curl -o /dev/null -sfw '%{content_type}' http://darkhttpd/msword.docx | grep '^application/vnd\.openxmlformats-officedocument\.wordprocessingml\.document$' >/dev/null
curl -o /dev/null -sfw '%{http_code}' http://darkhttpd/no-index | grep '^301$' >/dev/null
curl -o /dev/null -sfLw '%{http_code}' http://darkhttpd/no-index | grep '^404$' >/dev/null
curl -o /dev/null -I -sfw '%{http_code}' http://darkhttpd/has-index/ | grep '^200$' >/dev/null

echo "All tests have passed."
