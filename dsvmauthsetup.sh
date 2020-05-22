username="$1"
passwordsecretname="$2"
keyvaulturi="$3"
functioncode=$(</home/dsvmadmin/functioncode.txt)
password="$(curl "$keyvaulturi/api/Function1?Secret=$passwordsecretname&code=$functioncode" 2>/dev/null | jq -r '.Value')"
(echo $password; echo $password) | sudo passwd $username
