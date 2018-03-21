
Overview
========

- This note describes the mechanism used to tag DC/OS agents with the AZ they are in in order to allow distribution of containers (my marathon) by AZ.
- The objective of this is to ensure container instances can get evenly spread across all available AZs, instead of concentrating on one AZ, this leads to better distribution for high availability.

Requirements:
=============

- Should take the form of a container AZ distribution mechanism based on a Marathon constraint.
- Applies to microservices scaling to > 1 container.
- Should be applied via labels surfaced through Marathon


Problem analysis
================

Part A: pass the AZ attribute for each node/agent through with each offer from Mesos.
=================================================================

- This can be done using --attributes command-line flag of mesos-agent (http://mesos.apache.org/documentation/latest/attributes-resources/) E.g:

`
--attributes='az_id:us-east-1a;os:centos5;level:10;keys:1000-1500'
`

That will result in configuring the following attributes:

- availability zone with text value us-east-1
- os with text value centos5
- level with scalar value 10
- keys with range value 1000 through 1500 (inclusive)"

Part B: Configure marathon to use these attributes to distribute the tasks across the cluster:
=============================================================================================
=
- (In DC/OS, physical distribution of tasks can be accomplished by using the UNIQUE and GROUP_BY constraints operator.) https://docs.mesosphere.com/1.8/overview/high-availability/
NOTE: We should be able to Advertise the AZ attribute through mesos and distribute tasks evenly across nodes and AZs, as in the "GROUP_BY operator" in the following example which uses rack_ids instead of AZs:

`
$ curl -X POST -H "Content-type: application/json" localhost:8080/v2/apps -d '
{ "id": "sleep-group-by", "cmd": "sleep 60", "instances": 3, "constraints": [["rack_id", "GROUP_BY"]] }'
`


NOTE: From the documentation for GROUP BY operator:
`
"Marathon only knows about different values of the attribute (e.g. “rack_id”) by analyzing incoming offers from Mesos. If tasks are not already spread across all possible values, specify the number of values in constraints. If you don’t specify the number of values, you might find that the tasks are only distributed in one value, even though you are using the GROUP_BY constraint."
`

Note:
=====

Required to make sure new AZ property takes effect once added to the parameters file (/var/lib/dcos/mesos-slave-common):

`
systemctl kill -s SIGUSR1 dcos-mesos-slave && systemctl restart dcos-mesos-slave
`

NOTE: However this may cause the task to crash, due to what seems like a bug, so we'll need to confirm with mesosphere how to make new properties live without disturbing running services.

Implementation:
===============

- Tagging implemented in ansible script and nodes are tagged during install time.
- constraints are configured for services to use following that.

