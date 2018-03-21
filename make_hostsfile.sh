#!/bin/bash
#script to create an ansible hosts file based on output from terraform
#twelcome@teralytics.ch

function escape()
{
  local __resultvar=$1
  local result=`terraform output $1`
  result=$(printf '%s\n' "$result" | sed 's/^o://g;s,[\/&],\\&,g;s/$/\\/')
  result=${result%?}
  eval $__resultvar="'$result'"
}

# Create hosts file

hosts_src="./hosts.example"
hosts_dest="./hosts"

cp $hosts_src $hosts_dest

escape workstation_public_ips
escape master_public_ips
escape agent_public_ips
escape public_agent_public_ips

echo "1)"
sed -i "s/1.0.0.1/$workstation_public_ips/g" $hosts_dest
echo "2)"
sed -i "s/1.0.0.2/$master_public_ips/g" $hosts_dest
echo "3)"
sed -i "s/1.0.0.3/$agent_public_ips/g" $hosts_dest
echo "4)"
sed -i "s/1.0.0.4//g" $hosts_dest
echo "5)"
sed -i "s/1.0.0.5/$public_agent_public_ips/g" $hosts_dest
