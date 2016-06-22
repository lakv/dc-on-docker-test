#!/bin/bash

network=mgmt

# create a management network
create_management_network()
{
	docker network inspect ${network} > /dev/null
	if [ $? = 1 ]; then
		docker network create --internal \
			--subnet=10.11.12.0/24 \
			--gateway=10.11.12.254 ${network}
	fi
}

# connect all nodes to the management network
connect_to_management_network()
{
	for node in `docker ps --format '{{.Names}}'`; do
		docker inspect --format="{{ .NetworkSettings.Networks }}" ${node} | grep ${network}
		if [ $? = 1 ]; then
			docker network connect ${network} ${node}
		fi
	done
}

docker network rm ${network}

create_management_network
connect_to_management_network
