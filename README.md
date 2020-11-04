## Docker swarm MongoDB replica set

This is mainly a repo to deploy a MongoDB replica set for test & development
but feel free to use it as a simple guide.

### What you need

For this repo I'm using 4 servers but you don't have to.
Docker-compose.yaml can be changed to deploy everything on one server.
I'm also using local IPs but using DNS names is recommended.

### How to use

1. Create a custom mongodb image
2. Change docker-compose to fit your needs
3. Change mongo-example.env to mongo.env
4. Change username and password in mongo.env
5. Either run commands on a swarm manager or use docker-compose up

In same directory as Dockerfile:

```shell
$ openssl rand -base64 741 > mongo.key
$ docker build -t my-custom-mongodb-image .
```


On a swarm manager:

```shell
$ docker stack deploy -c docker-compose.yaml <stack-name>
```

Make sure all services are up

```shell
$ docker service ls
```

Exec into a running container

```shell
$ docker exec -it <container-name> bash
```

Log in to mongo instance inside the container.
Same username and password which was set in mongo.env

```shell
$ mongo -u admin -p admin-password
```


Initiate replica set. Change to fit your needs.

```shell
$ rs.initiate(
  {_id:"rs0",
    members:
      [
        {_id:0,host:"192.168.86.21:27017","priority":1},
        {_id:1,host:"192.168.86.22:27018"},
        {_id:2,host:"192.168.86.23:27019"},
        {_id:3,host:"192.168.86.24:27020"}
       ]
     })
```

Run these two commands and ensure you see ok:1 and that there's a PRIMARY in the replica set.
If it does not change to PRIMARY after rs.conf() - wait a few seconds and run it again.
The replica set might take a few seconds to connect all nodes.

```shell
rs0:SECONDARY> rs.conf()
rs0:PRIMARY> rs.status()
```

Now you can connect to the replica set from any application.
All commands are to be ran on the PRIMARY node.
To add a user:

```shell
rs0:PRIMARY> use database-name
'switched to db database-name'
rs0:PRIMARY> db.createUser(
   {
     user: "a-user-name",
     pwd: "a-secure-password,
     roles:
       [
         { role: "readWrite", db: "database-name" }
       ]
   })
```

A connection string connecting from MongoDB Compass:
```shell
mongodb://user-name:user-password@HOST1:27017,HOST2:27018,HOST3:27019,HOST4:27020/?authSource=database-name&replicaSet=rs0
```

A connection string connecting with Mongoose / NodeJS
```shell
mongodb://user-name:user-password@HOST1:27017,HOST2:27018,HOST3:27019,HOST4:27020/database-name?replicaSet=rs0
```
