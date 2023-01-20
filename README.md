A docker version of Original LibreSpeed is available on docker hub: [https://hub.docker.com/r/mikedye0511/speedtest/](https://hub.docker.com/r/mikedye0511/speedtest/)

My Updated Version of SpeedTest is available on docker hub: [https://hub.docker.com/repository/docker/mikedye0511/speedtest/](https://hub.docker.com/repository/docker/mikedye0511/speedtest/)

## Downloading from Docker hub
To download LibreSpeed from the docker hub, use this command:

```
docker pull mikedye0511/speedtest
```

You will now have a new docker image called `mikedye0511/speedtest`.

## Standalone mode with HTTP Only
If you want to install LibreSpeed on a single server, you need to configure it in standalone mode. To do this, set the `MODE` environment variable to `standalone`.

The test can be accessed on port 80, 443

Here's a list of additional environment variables available in this mode:
* __`TITLE`__: Title of your speedtest. Default value: `LibreSpeed`
* __`SSL`__: Enable HTTP and HTTPS. If __`CUSTOM_CERTS`__ set to false or not set, it will create selfsigne certs. Default Value: 'false'
* __`CUSTOM_CERTS`__: Allows for Public Certs to be used. Defaullt value: 'false'
* __`TELEMETRY`__: Whether to enable telemetry or not. Default value: `false`
* __`ENABLE_ID_OBFUSCATION`__: When set to true with telemetry enabled, test IDs are obfuscated, to avoid exposing the database internal sequential IDs. Default value: `false`
* __`REDACT_IP_ADDRESSES`__: When set to true with telemetry enabled, IP addresses and hostnames are redacted from the collected telemetry, for better privacy. Default value: `false`
* __`PASSWORD`__: Password to access the stats page. If not set, stats page will not allow accesses.
* __`EMAIL`__: Email address for GDPR requests. Must be specified when telemetry is enabled.
* __`IPINFO_APIKEY`__: API key for ipinfo.io. Optional, but required if you expect to serve a large number of tests
* __`DISABLE_IPINFO`__: If set to true, ISP info and distance will not be fetched from ipinfo.io. Default: value: `false`
* __`DISTANCE`__: When `DISABLE_IPINFO` is set to false, this specifies how the distance from the server is measured. Can be either `km` for kilometers, `mi` for miles, or an empty string to disable distance measurement. Default value: `km`
* __`WEBPORT`__: Allows choosing a custom port for the included web server. Default value: `80`. Note that you will have to expose it through docker with the -p argument
* __`SSLPORT`__: Allows choosing a custom port for the included web server. Default value: `443`. Note that you will have to expose it through docker with the -p argument

If telemetry is enabled, a stats page will be available at `http/s://your.server/results/stats.php`, but a password must be specified.

#### Example
##### This command starts LibreSpeed in standalone mode, with the default settings, on port 80 and no SSL.

```
docker run -e MODE=standalone -p 80:80 -it mikedye0511/speedtest
```

##### This command starts LibreSpeed in standalone mode, with the default settings, SelfSigned Certs

```
docker run -e MODE=standalone -e SSL=true -p 80:80 -p 443:443 -it mikedye0511/speedtest
```

##### This command starts LibreSpeed in standalone mode, with the default settings, Public Signed Certs

```
docker run -e MODE=standalone -e SSL=true -e CUSTOM_CERTS=true -v $(pwd)/public.pem:/etc/ssl/certs/public_crt.pem  -v $(pwd)/private.pem:/etc/ssl/private/private_crt.key -p 80:80 -p 443:443 -it mikedye0511/speedtest
```

##### This command starts LibreSpeed in standalone mode, with telemetry, ID obfuscation and a stats password, on port http 90 and https 9443:

```
docker run -e MODE=standalone -e SSL=true -e TELEMETRY=true -e ENABLE_ID_OBFUSCATION=true -e PASSWORD="yourPasswordHere" -e WEBPORT=90 -e SSLPORT=9443 -p 90:90 -p 9443:443 -it mikedye0511/speedtest
```



## Multiple Points of Test
For multiple servers, you need to set up 1+ LibreSpeed backends, and 1 LibreSpeed frontend.

Note: If using TLS/HTTPS Mode, in Frontend and Backend Mode, you will need to use Public Signed Certs, as it causes CORS to fail.
If you do not need TLS/HTTPS do not enable HTTPS.

### Backend mode
In backend mode, LibreSpeed provides only a test point with no UI. To do this, set the `MODE` environment variable to `backend`.

The following backend files can be accessed on port 80/443: `garbage.php`, `empty.php`, `getIP.php`

Here's a list of additional environment variables available in this mode:
* __`IPINFO_APIKEY`__: API key for ipinfo.io. Optional, but required if you expect to serve a large number of tests

#### Example:
##### This command starts LibreSpeed in backend mode, with the default settings, on port 80:
```
docker run -e MODE=backend -p 80:80 -it mikedye0511/speedtest
```

##### This command starts LibreSpeed in backend mode, with the default settings, on http and https:
```
docker run -e MODE=backend -e SSL=true -p 80:80 -p 443:443 -it mikedye0511/speedtest
```

Here's a list of additional environment variables available in this mode:
* __`SSL`__: Enable HTTP and HTTPS. If __`CUSTOM_CERTS`__ set to false or not set, it will create selfsigne certs. Default Value: 'false'
* __`CUSTOM_CERTS`__: Allows for Public Certs to bound. Defaullt value: 'false'
* __`WEBPORT`__: Allows choosing a custom port for the included web server. Default value: `80`. Note that you will have to expose it through docker with the -p argument
* __`SSLPORT`__: Allows choosing a custom port for the included web server. Default value: `443`. Note that you will have to expose it through docker with the -p argument


### Frontend mode
In frontend mode, LibreSpeed serves clients the Web UI and a list of servers. To do this:
* Set the `MODE` environment variable to `frontend`
* Create a servers.json file with your test points. The syntax is the following:
    ```
    [
        {
            "name": "Friendly name for Server 1",
            "server" :"//server1.mydomain.com/",
            "dlURL" :"garbage.php",
            "ulURL" :"empty.php",
            "pingURL" :"empty.php",
            "getIpURL" :"getIP.php"
        },
        {
            "name": "Friendly name for Server 2",
            "server" :"https://server2.mydomain.com/",
            "dlURL" :"garbage.php",
            "ulURL" :"empty.php",
            "pingURL" :"empty.php",
            "getIpURL" :"getIP.php"
        },
        ...more servers...
    ]
    ```
    Note: if a server only supports HTTP or HTTPS, specify the protocol in the server field. If it supports both, just use `//`.
* Mount this file to `/servers.json` in the container (example at the end of this file)
    
The test can be accessed on port 80.

Here's a list of additional environment variables available in this mode:
* __`TITLE`__: Title of your speedtest. Default value: `LibreSpeed`
* __`SSL`__: Enable HTTP and HTTPS. If __`CUSTOM_CERTS`__ set to false or not set, it will create selfsigne certs. Default Value: 'false'
* __`CUSTOM_CERTS`__: Allows for Public Certs to bound. Defaullt value: 'false'
* __`TELEMETRY`__: Whether to enable telemetry or not. Default value: `false`
* __`ENABLE_ID_OBFUSCATION`__: When set to true with telemetry enabled, test IDs are obfuscated, to avoid exposing the database internal sequential IDs. Default value: `false`
* __`REDACT_IP_ADDRESSES`__: When set to true with telemetry enabled, IP addresses and hostnames are redacted from the collected telemetry, for better privacy. Default value: `false`
* __`PASSWORD`__: Password to access the stats page. If not set, stats page will not allow accesses.
* __`EMAIL`__: Email address for GDPR requests. Must be specified when telemetry is enabled.
* __`DISABLE_IPINFO`__: If set to true, ISP info and distance will not be fetched from ipinfo.io. Default: value: `false`
* __`DISTANCE`__: When `DISABLE_IPINFO` is set to false, this specifies how the distance from the server is measured. Can be either `km` for kilometers, `mi` for miles, or an empty string to disable distance measurement. Default value: `km`
* __`WEBPORT`__: Allows choosing a custom port for the included web server. Default value: `80`
* __`SSLPORT`__: Allows choosing a custom port for the included web server. Default value: `443`. Note that you will have to expose it through docker with the -p argument

#### Example
This command starts LibreSpeed in frontend mode, with a given `servers.json` file, and with telemetry, ID obfuscation, and a stats password:
```
docker run -e MODE=frontend -e TELEMETRY=true -e ENABLE_ID_OBFUSCATION=true -e PASSWORD="yourPasswordHere" -v $(pwd)/servers.json:/servers.json -p 80:80 -it mikedye0511/speedtest
