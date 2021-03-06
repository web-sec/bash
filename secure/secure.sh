#!/bin/bash

MY_DATE='12.10.1990'
echo "My birth date is: $MY_DATE"
echo ''
MY_DATE_SUM=0
for i in $(echo $MY_DATE | grep -o '[0-9]'); do
        MY_DATE_SUM=$[$MY_DATE_SUM + $i]
done
#EXERCISE 1 START
echo "========================================================="
echo "STARTING EXERCISE 1..."
echo "========================================================="
for ((i=1; i<=10; i++)); do
         MY_NUMBER_1=$((((MY_DATE_SUM + RANDOM)) % 106))
         echo "My number is: $MY_NUMBER_1"
         ipaddr="$(sed -n "${MY_NUMBER_1}p" names.txt | tr -d ' ' | tr -d '\n')"
         
         if [[ "$ipaddr" ]]; then
                 find_ip_addr="$(dig +short $ipaddr)"
                 if [[ "$find_ip_addr" ]]; then
                         each_new_ip=''
                         for each_ip in $find_ip_addr; do
                             each_new_ip+=" $each_ip"
                         done
                         
                         dig_name="$(dig -x $find_ip_addr)"
                         name=$(echo "$dig_name" | grep -v "^$" | grep -v "^;" | head -n1 | awk '{print $1;}')
                         names=$(echo "$dig_name" | grep -v "^$" | grep -v "^;" | awk '{$1=$2=$3=$4=""; print $0}')
                         each_new_name=''
                         for each_name in $names; do
                             if [[ "$each_name" == *.* ]]; then
                                each_new_name+=" $each_name"
                             fi
                         done
                         echo "$name$each_new_ip $each_new_name"

                         
                 else
                         echo "No IP was found for host: $ipaddr"
                 fi
         else
                 echo "Couldn't find IP"
         fi
         echo ""
         
done
echo "========================================================="
echo "EXERCISE 1 DONE"
echo "========================================================="
#EXERCISE 1 END
echo ''
#EXERCISE 2 START
echo "========================================================="
echo "STARTING EXERCISE 2..."
echo "========================================================="

function get_xml_value () {
         #find_abuse=$(curl -s "http://rest.db.ripe.net/search?query-string=$1" | grep "$2" | head -n1 | grep -oP '(?<=value=").*(?=")')
	find_value=$(whois -h whois.ripe.net $1 | grep $2 | head -n1 | grep -oP "(?<=$2).*" | tr -d ' ')         
	if [[ "$find_value" ]]; then
		echo "$find_value" 
	fi
}

for ((i=1; i<=20; i++)); do
       MY_NUMBER_2=$((((MY_DATE_SUM + RANDOM)) % 2000 + 400))
       echo "My number is: $MY_NUMBER_2"
       ipaddr="$(sed -n "${MY_NUMBER_2}p" ips.txt)"
       if [[ "$ipaddr" ]]; then
               fixed_ipaddr=$(echo $ipaddr | grep -iPo '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')
               if [[ "$fixed_ipaddr" ]]; then
                       
                       check_status=$(get_xml_value "$fixed_ipaddr" "status")
                       
                       if [[ "$check_status" == *UNSPECIFIED* ]]; then
                               #get_owner=$(dig +short -x "$fixed_ipaddr")
                               echo "$fixed_ipaddr is UNSPECIFIED."
                       else

                               address=$(get_xml_value "$fixed_ipaddr" "descr:")
                               if [[ "$address" == *"reports to other"* ]]; then
                                  address="no_address"
                               fi
                               
                               abuse_mail=$(get_xml_value "$fixed_ipaddr" "abuse-mailbox:")
                               if [ -z "$abuse_mail" ]; then
                                  abuse_mail="no_abuse_email"
                               fi
                               
                               country=$(get_xml_value "$fixed_ipaddr" "country:")
                               if [ -z "$country" ]; then
                                  country="no_country"
                               fi
				country_name=$(geoiplookup $fixed_ipaddr | head -n1 | cut -d "," -f2 | tr -d ' ')
				cert_ln="$(grep -nrw "^$country_name$" cert.txt | cut -d ":" -f1)"
				abuse_contacts="$(sed -n "$((cert_ln+3))"p cert.txt)"

				if [ -z "$abuse_contacts" ]; then
					abuse_contacts="no_contact_for_$country_name"
				fi
                               #echo $country_name
                               echo "$fixed_ipaddr $address $country $abuse_mail $abuse_contacts"
                       fi
                               
                       #fi
                       #194.106.111.42 abuse@elion.ee RT Tarkvara OY CERT-EE cert@cert.ee
                       #echo "$fixed_ipaddr 
                       #echo "No hostname was found for IP: $fixed_ipaddr"
                               
               else
                       echo 'Result from ips.txt is not IP address.'
               fi
       else
               echo "No result from ips.txt"
       fi
       echo ""
done
echo "========================================================="
echo "EXERCISE 2 DONE"
echo "========================================================="
#EXERCISE 2 END
echo ''
#EXERCISE 4 START
echo "========================================================="
echo "STARTING EXERCISE 4..."
echo "========================================================="
MY_NUMBER_3=$((((MY_DATE_SUM + RANDOM)) % 3228 ))
for ((i=1; i<=10; i++)); do
       echo "My number is: $MY_NUMBER_3"
       ip6addr="$(sed -n "${MY_NUMBER_3}p" ips6.txt)"
       if [[ "$ip6addr" ]]; then
               
               cert_code=''
               abuse_contacts=''

               h_country_name=$(geoiplookup6 $ip6addr | head -n1 | cut -d "," -f2 | tr -d ' ' )
		
             

	       if [[ "$h_country_name" == *cant* ]]; then
                     country_name=''
                     country_code=''
               else
                     country_name=$(geoiplookup6 $ip6addr | head -n1 | cut -d "," -f2 | tr -d ' ')
		     country_code=$(geoiplookup6 $ip6addr | head -n1 | cut -d ":" -f2 | cut -d "," -f1)
                     cert_ln="$(grep -nrw "^$country_name$" cert.txt | cut -d ":" -f1)"
                     cert_code="$(sed -n "$((cert_ln+1))"p cert.txt)"
                     abuse_contacts="$(sed -n "$((cert_ln+3))"p cert.txt)"
               fi
               
               address=$(get_xml_value "$fixed_ipaddr" "descr:")
               if [[ "$address" == *"reports to other"* ]]; then
                  descr="no_address"
               fi
               
               abuse_mail=$(get_xml_value "$ip6addr" "abuse-mailbox:")
               if [ -z "$abuse_mail" ]; then
                  abuse_mail="no_abuse_email"
               fi
               #echo "$country_name"
		AS_NUMBER=$(whois -h whois.cymru.com "$ip6addr" | tail -1 | cut -d " " -f1)
		address=$(whois -h whois.cymru.com "$ip6addr" | tail -1 | cut -d "|" -f3)
               echo "$ip6addr $AS_NUMBER $address $country_code $country_name $abuse_mail $cert_code  $abuse_contacts"

       else
               echo "No result from ips.txt"
       fi
       ((MY_NUMBER_3=MY_NUMBER_3 + 40))
       echo ""
done
echo "========================================================="
echo "EXERCISE 4 DONE"
echo "========================================================="
echo ''
#EXERCISE 4 END
