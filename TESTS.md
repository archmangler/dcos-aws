DC/OS Deployment and Configuration Validation Tests
===================================================

Contents:
=========

Testing Service distribution across AZs

 - Procedure for testing that service instances get deployed evenly across the available AZs based on tags on slave agents.
 - use the following constraint configuration on microservices (will vary depending on available AZs in the region, here we assume 4)

`
  "constraints": [[ "az_id", "GROUP_BY", "4" ]],
`

- Step 1: Create a sample app as follows:

`
{
  "id": "dcos-website",
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "mesosphere/dcos-website:cff383e4f5a51bf04e2d0177c5023e7cebcab3cc",
      "network": "BRIDGE",
      "portMappings": [
        { "hostPort": 0, "containerPort": 80, "servicePort": 10004 }
      ]
    }
  },
  "instances": 4,
  "constraints": [[ "az_id", "GROUP_BY", "4" ]],
  "cpus": 0.25,
  "mem": 100,
  "healthChecks": [{
      "protocol": "HTTP",
      "path": "/",
      "portIndex": 0,
      "timeoutSeconds": 2,
      "gracePeriodSeconds": 15,
      "intervalSeconds": 3,
      "maxConsecutiveFailures": 2
  }],
  "labels":{
    "HAPROXY_DEPLOYMENT_GROUP":"dcos-website",
    "HAPROXY_DEPLOYMENT_ALT_PORT":"10005",
    "HAPROXY_GROUP":"external",
    "HAPROXY_0_REDIRECT_TO_HTTPS":"true",
    "HAPROXY_0_VHOST":"<public node's private IP>"
  }
}
`

Step 2: 

- Deploy the app: dcos marathon app add test.json

Step 3: 

- Check that the 4 instances have been deployed on different agents in roughly different AZs
 
Step 4: 

- Scale up to 8 instances of the app and check that they're deployed roughly evenly across all AZs

Step 5: 

- Scale down and check that the instance distribution across Azs is still roughly even.

