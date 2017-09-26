# Node Data Dependencies

Although all Perseids instances can be boostrapped using Puppet, some services
have databases which need restoration from backup in order to replicate the 
current production environment.

## Annotation Node

### Marmotta

Restore the Postgres db for Marmotta:

```
duplicity_restore marmotta_db /tmp/marmotta_db
sudo su - postgres
gunzip /tmp/<latest zip file here>
psql marmotta < /tmp/<unzipped file>
rm -fr /tmp/marmotta_db
```

### Imgup/Jackson

Restore the image binary and json files from the S3 buckets:

Ensure that the server you're installing on has sufficient disk space on the root device (50GB Volume should do).

As root:

```
duplicity_restore www_imgjson /var/www/JackSON/data
chown -R www-data /var/www/JackSON/data

duplicity_restore www_imgdata /usr/local/imgdata
chown -R deployer /usr/local/imgdata
```

## Services Node

## Fuseki

Restore the Fuseki data.

As root:

```
duplicity_restore fuseki_data /tmp/fusekiDB
service fuseki stop
cp -r /tmp/fusekiDB/* /usr/local/jena-fuseki-1.0.2/DB
service fuseki start
```

## SoSOL Node

See 
  * [Build a new Sosol server](Build%20a%20new%20Sosol%20server.md) 
  * [Make a Staging SoSOL MySQL DB](Make%20a%20Staging%20SoSOL%20MySQL%20DB.md)
  * [Restore Sosol data from SQL dump](Restore%20Sosol%20data%20from%20SQL%20dump.md)


