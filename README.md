# Shamwow
Shamwow is a swiss army knife for Chef maintenance. It upgrades chef-clients through SSH, running the chef-client both before and after, capturing all the output and storing it in a postgres db.   It also pulls data from Chef, Dns, SSH, and Marchex's homegrown network tools and puts it into a postgres database. 

## Options
```
    --host,           run on a hostname, default: nil
    --from,           hosts from a file, default: nil
    --fromdb,         hosts from hsots table, default: false
    --connection,     postgres connection string, default: ENV[CONNECTIONSTRING]
    --sshtasks,       a list of sshtasks to execute, default: [Chef_version], delimiter: ,
    -u, --user,       the user to connect to using ssh, default: ENV[USER]
    -P, --password,   read password from args, default: nil
    -p, --askpass,    read password from stdlin, default: false
    --dns,            poll dns
    --ssh,            poll ssh
    --net,            poll network engineerings website
    --knife,          poll knife status
    --dbdebug,        dumps ORM\s raw sql, default: false
    --version,        print the version do
```

## Data sources

### Shamwow DB
As Shamwow builds a list of known hosts, it can scan them periodically to refresh the DB. Use the --fromdb option.

### SSH 
Shamwow can execute a numple of tasks through SSH. It can upgrade or downgrade a Chef client through SSH.  Chef does provides complete tools for managing clients; this was written ot be able to audit any action across a heterogenous snowflake field. 

Shamwow also collects information  about the node from SSH and populates the 
_shamwow_ssh_data_ table. This table doesn't keep history; the data reflects the most recent run, and includes:

* os & chefver: The OS reported from /etc/issue and the version from `chef-client --version`
* chef_lsof_count: The open filehandles of the chef-client
* chef_strace_method & chef_strace_full: The method and full stacktrace of the last chef failure 
* nrpe_chefcheck_checksum & nrpe_chefcheck_fileinfo: Used when tracking check_chef_fatal.sh improvements

There is also an _shamwow_ssh_exec_data_ table that stores output from multiple executions, with usually larger output activities. The actions available that populate this table are:

* chef_upgrade
* chef_downgrade
* chef_chmod_stacktrace  -- Duplicate functionality; keeps a searchble history
* chec_start
* chef_stop
* chef_run
* verify_running_version
* gem_list_ldap
* upgrade_check_chef_fatal

### DNS
Shamwow SSHs to a bastion host and performs a `dig axfr marchex.com`. The data is stored in _shamwow_dns_data_ table.  The list of servers polled is currecntly hardcoded in the `lib/shamwow.rb` file. 

### Chef Server
Shamwow uses knife to extract and normalize node data for SQL-based analysis. It pulls the cookbooks,
roles, and run_list from each node and normalizes it in tables with references for aggregation.

It parses output from the following commands:
* knife status -F json 'fqdn:*'
* knife search node 'fqdn:*' -a cookbooks -a roles -a run_list -Fj

It uses the following tables to store the 1-n relations between nodes, cookboks, runs, and the run_list:
* shamwow_knife_ckbk_links
* shamwow_knife_ckbks
* shamwow_knife_data
* shamwow_knife_role_links
* shamwow_knife_roles
* shamwow_knife_runlist_links
* shamwow_knife_runlists

The ckbks, roles, and runlists tables contain unique entries for each cookbook+version, role, and runlist just the respective name. The _links table store the n-n relationship with knife_data. Stale links table entries are expired each run.

### HTTP
Shamwow pulls some network layers 1-3 data from custom HTTP endpoints. These could be refactored
to parse standard data from current NMS tools. The data captures is listed below:

* layer 1: ethswitch, interface, linkstate, and description
* layer 2: ethswitch, interface, machaddress, macprefix, vlan
* layer 3: ipgateway, port, macaddress, ipaddress, macprefix, reverse dns lookup

### SNMP
Shamwow parsed some SNMP data that was hand-extracted; the feature was never completed.

## Setup 
Shamwow can be executed from the source repo, or from a docker container. There is a Dockerfile in the root of the repo for shamwow. There's a minimal setup for a  postgres container in /dockerfiles/db. Shamwow will create a new instance of its database if it does not exist.

## Logging
Shamwow has an internal log, recording execution of activities. Use of the logging feature within the code is not 100%. The data is stored in the _shamwow_log_data_ table.

