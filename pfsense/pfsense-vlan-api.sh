#!/bin/bash


# Action control
case $1 in
  addvlan)
    action=1
    ;;

  addinterface)
    action=2
    ;;

  addvirtualip)
    action=3
    ;;

  addall)
    action=4
    ;;

  *)
    echo "No valid option provided, the script will use 'addall' by default."
    action=4
    ;;
esac

#host="10.10.1.2"
host="10.11.1.3"

url="http://${host}/api/v1/access_token"

#csv=./pfsense-vlan.csv
#csv=./pfsense-vlan-labp01.csv
#csv=./pfsense-vlan-labp02.csv
#csv=./pfsense-vlan-labpf11.csv
csv=./pfsense-vlan-labpf12.csv

echo "Please provide your pfsense credential"
read -p "Enter username: " user

read -sp "Enter password: " pass

# get the bearer token
token=$(curl -s -k -u ${user}:${pass} -X POST ${url} | jq '.data.token' | sed 's/\"//g')

# echo "show token"
# echo "$token"

addvlan () {
    while IFS=, read -r descr interface pcp tag iftag ip subnet vhid vip advbase advskew mode carppassword
    do
      echo "$descr $interface $pcp $tag $iftag $ip $subnet $vhid $vip $advbase $advskew $mode $carppassword"
      #sleep 1
      curl -k -X 'POST' \
      "http://${host}/api/v1/interface/vlan" \
      -H 'accept: application/json' \
      -H "Authorization: Bearer $token" \
      -H 'Content-Type: application/json' \
      -d "{
            \"descr\": \"${descr}\",
            \"if\": \"${interface}\",
            \"pcp\": ${pcp},
            \"tag\": ${tag}
        }"
  done < $csv
}

addinterface() {
    while IFS=, read -r descr interface pcp tag iftag ip subnet vhid vip advbase advskew mode carppassword
    do
      echo "$descr $interface $pcp $tag $iftag $ip $subnet $vhid $vip $advbase $advskew $mode $carppassword"
      #sleep 1
      curl -k -X 'POST' \
      "http://${host}/api/v1/interface" \
      -H 'accept: application/json' \
      -H "Authorization: Bearer $token" \
      -H 'Content-Type: application/json' \
      -d "{
            \"descr\": \"VLAN${tag}\",
            \"enable\": true,
            \"if\": \"${iftag}\",
            \"ipaddr\": \"${ip}\",
            \"subnet\": ${subnet},
            \"type\": \"staticv4\",
            \"apply\": true

        }"
  done < $csv
}

addvirtualip() {
    while IFS=, read -r descr interface pcp tag iftag ip subnet vhid vip advbase advskew mode carppassword
    do
      echo "$descr $interface $pcp $tag $iftag $ip $subnet $vhid $vip $advbase $advskew $mode $carppassword"
      #sleep 1

      tmppass="$carppassword"
      curl -k -X 'POST' \
      "http://${host}/api/v1/firewall/virtual_ip" \
      -H 'accept: application/json' \
      -H "Authorization: Bearer $token" \
      -H 'Content-Type: application/json' \
      -d "{
            \"advbase\": ${advbase},
            \"advskew\": ${advskew},
            \"descr\": \"\",
            \"interface\": \"${iftag}\",
            \"mode\": \"${mode}\",
            \"noexpand\": false,
            \"password\": \"${tmppass}\",
            \"subnet\": \"${vip}/${subnet}\",
            \"vhid\": ${vhid}
        }"
  done < $csv
}



# Actual call function depends on action
case $action in
  1)
    addvlan
    ;;

  2)
    addinterface
    ;;

  3)
    addvirtualip
    ;;

  4)
    addvlan
    sleep 2
    addinterface
    sleep 2
    addvirtualip
    ;;
esac


