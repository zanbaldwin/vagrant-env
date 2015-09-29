# Git Branch Detector
function parse_git_branch ()
{
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# WHOIS a domain or URL.
function whois()
{
    local domain=$(echo "$1" | awk -F/ '{print $3}')
    if [ -z $domain ] ; then
        domain=$1
    fi
    echo "Getting whois record for: $domain …"
    /usr/bin/whois -h whois.internic.net $domain | sed '/NOTICE:/q'
}
