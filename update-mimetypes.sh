#!/bin/sh
curl 'http://hg.nginx.org/nginx/raw-file/default/conf/mime.types' | perl -pe '
    s,^\s+,,g;
    s,\s+$,,g;
    if (m/;$/) {
        $_ = "$_\n";
    } elsif (!m/^$/) {
        $_ = "$_ ";
    }
    $_ = "" if ($_ eq "types { " || $_ eq "} ");
' | perl -pe '
    if (m/^([^\s]+)\s+([^\s].*);$/) {
        $_ = sprintf("%-79s %s\n", $1, $2);
    }
' >mime.types
