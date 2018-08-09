# ZooKeeper CLI Client Example

## Sample Code

```Shell
zkCli.sh -server localhost:2181

# Switch to super user.
[0] addauth digest super:super

# Only allow all users create nodes on root path /.
[1] setAcl / world:anyone:c

# Grant all permissions to all users on path /lost.
[2] setAcl /lost world:anyone:cdrwa
```

```
zkCli.sh -server localhost:2181

# Switch to another user.
[0] addauth digest jack:jack

# Create the user's own node. Other users (except the super user) will not be able to do any operations on this node.
[1] create /jack Jack auth:jack:jack:cdrwa
```

## Further Reading

* [ZooKeeper Programmer's Guide](http://zookeeper.apache.org/doc/r3.4.13/zookeeperProgrammers.html#sc_ZooKeeperAccessControl)
* [ZooKeeper Administrator's Guide](http://zookeeper.apache.org/doc/r3.4.13/zookeeperAdmin.html#sc_authOptions)
* [ZooKeeper - Super User Authentication and Authorization](https://community.hortonworks.com/articles/29900/zookeeper-using-superdigest-to-gain-full-access-to.html)
