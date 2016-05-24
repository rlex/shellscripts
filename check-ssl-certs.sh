#This script will check CN validity and expiration date for SSL certificate
#Do not work with subjectAltName
#array of domains to check
ssl_domains=( google.com google.ru )

for domain in ${ssl_domains[@]}; do
  echo "SSL certificate data for ${domain}: "
  cert_data_common=$(echo | openssl s_client -servername $domain -connect $domain:443 2>/dev/null | openssl x509 -noout -subject | sed -e 's/^subject.*CN=\([a-zA-Z0-9\.\-\*]*\).*$/\1/')
  echo "Common name value: ${cert_data_common}"
  if [[ ${cert_data_common} != *${domain}* ]]; then
    echo "$(tput setaf 1)WARNING: CN MISMATCH$(tput sgr0)"
  fi
  cert_data_issuer=$(echo | openssl s_client -servername $domain -connect $domain:443 2>/dev/null | openssl x509 -noout -issuer | perl -lne 'print $1 if /CN=(.*)/')
  echo "Issued by: ${cert_data_issuer}"
  cert_data_expiry=$(echo | openssl s_client -servername $domain -connect $domain:443 2>/dev/null | openssl x509 -noout -subject -issuer -dates | awk -F= ' /notAfter/ { printf("%s\n",$NF); } ')
  seconds_until_expiry=$(echo "$(date --date="$cert_data_expiry" +%s) - $(date +%s)" | bc);
  days_until_expiry=$(echo "$seconds_until_expiry/(60*60*24)" | bc);
  echo "Expires in: ${days_until_expiry} days"
  echo ""
done
