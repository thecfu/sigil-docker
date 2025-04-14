---

# sigil-ebooks

A containerized version of **Sigil**, the free EPUB ebook editor, using [linuxserver/docker-baseimage-kasmvnc](https://github.com/linuxserver/docker-baseimage-kasmvnc) for GUI access via web.

---

## Application Setup

Access the application via:

- `http://<host>:3000/`
- `https://<host>:3001/`

> Modern GUI desktop apps have issues with the latest Docker and syscall compatibility, you can use Docker with the --security-opt seccomp=unconfined setting to allow these syscalls on hosts with older Kernels or libseccomp
---

### Security

> [!CAUTION]
> Do not put this on the Internet if you do not know what you are doing.
> By default this container has no authentication and the optional environment variables CUSTOM_USER and PASSWORD to enable basic http auth via the embedded NGINX server should only be used to locally secure the container from unwanted access on a local network. If exposing this to the Internet we recommend putting it behind a reverse proxy, such as SWAG, and ensuring a secure authentication solution is in place. From the web interface a terminal can be launched and it is configured for passwordless sudo, so anyone with access to it can install and run whatever they want along with probing your local network.

### Options in all KasmVNC based GUI containers

This container is based on [Docker Baseimage KasmVNC](https://github.com/linuxserver/docker-baseimage-kasmvnc) which means there are additional environment variables and run configurations to enable or disable specific functionality.

#### Optional environment variables

| Variable | Description |
| :----: | --- |
| CUSTOM_PORT | Internal port the container listens on for http if it needs to be swapped from the default 3000. |
| CUSTOM_HTTPS_PORT | Internal port the container listens on for https if it needs to be swapped from the default 3001. |
| CUSTOM_USER | HTTP Basic auth username, abc is default. |
| PASSWORD | HTTP Basic auth password, abc is default. If unset there will be no auth |
| SUBFOLDER | Subfolder for the application if running a subfolder reverse proxy, need both slashes IE `/subfolder/` |
| TITLE | The page title displayed on the web browser, default "KasmVNC Client". |
| FM_HOME | This is the home directory (landing) for the file manager, default "/config". |
| START_DOCKER | If set to false a container with privilege will not automatically start the DinD Docker setup. |
| DRINODE | If mounting in /dev/dri for [DRI3 GPU Acceleration](https://www.kasmweb.com/kasmvnc/docs/master/gpu_acceleration.html) allows you to specify the device to use IE `/dev/dri/renderD128` |
| DISABLE_IPV6 | If set to true or any value this will disable IPv6 | 
| LC_ALL | Set the Language for the container to run as IE `fr_FR.UTF-8` `ar_AE.UTF-8` |
| NO_DECOR | If set the application will run without window borders in openbox for use as a PWA. |
| NO_FULL | Do not autmatically fullscreen applications when using openbox. |

#### Optional run configurations

| Variable | Description |
| :----: | --- |
| `--privileged` | Will start a Docker in Docker (DinD) setup inside the container to use docker in an isolated environment. For increased performance mount the Docker directory inside the container to the host IE `-v /home/user/docker-data:/var/lib/docker`. |
| `-v /var/run/docker.sock:/var/run/docker.sock` | Mount in the host level Docker socket to either interact with it via CLI or use Docker enabled applications. |
| `--device /dev/dri:/dev/dri` | Mount a GPU into the container, this can be used in conjunction with the `DRINODE` environment variable to leverage a host video card for GPU accelerated applications. Only **Open Source** drivers are supported IE (Intel,AMDGPU,Radeon,ATI,Nouveau) |

### Application management

#### PRoot Apps

If you run system native installations of software IE `sudo apt-get install filezilla` and then upgrade or destroy/re-create the container that software will be removed and the container will be at a clean state. For some users that will be acceptable and they can update their system packages as well using system native commands like `apt-get upgrade`. If you want Docker to handle upgrading the container and retain your applications and settings we have created [proot-apps](https://github.com/linuxserver/proot-apps) which allow portable applications to be installed to persistent storage in the user's `$HOME` directory and they will work in a confined Docker environment out of the box. These applications and their settings will persist upgrades of the base container and can be mounted into different flavors of KasmVNC based containers on the fly. This can be achieved from the command line with:

```
proot-apps install filezilla
```

PRoot Apps is included in all KasmVNC based containers, a list of linuxserver.io supported applications is located [HERE](https://github.com/linuxserver/proot-apps?tab=readme-ov-file#supported-apps).


## Usage

To help you get started creating a container from this image you can either use docker-compose or the docker cli.

> [!IMPORTANT]
> Unless a parameter is flaged as 'optional', it is *mandatory* and a value must be provided.

### docker-compose (recommended, [click here for more info](https://docs.linuxserver.io/general/docker-compose))

```yaml
---
services:
  sigil:
    image: ghcr.io/thecfu/sigil-docker:latest
    container_name: sigil
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - /path/to/books:/books
      - /path/to/config:/home/abc/.local/share/sigil-ebook
    ports:
      - 3000:3000
      - 3001:3001
    restart: unless-stopped
```

### docker cli ([click here for more info](https://docs.docker.com/engine/reference/commandline/cli/))

```bash
docker run -d \
  --name=sigil \
  --security-opt seccomp=unconfined `#optional` \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -p 3000:3000 \
  -p 3001:3001 \
  -v /path/to/books:/books \
  -v /path/to/config:/home/abc/.local/share/sigil-ebook \
  --restart unless-stopped \
  ghcr.io/thecfu/sigil-docker:latest
```

## Parameters

Containers are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

### Ports (`-p`)

| Parameter | Function |
| :----: | --- |
| `3000:3000` | Sigil desktop gui. |
| `3001:3001` | Sigil desktop gui HTTPS. |

### Environment Variables (`-e`)

| Env | Function |
| :----: | --- |
| `PUID=1000` | for UserID - see below for explanation |
| `PGID=1000` | for GroupID - see below for explanation |
| `TZ=Etc/UTC` | specify a timezone to use, see this [list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List). |
| `SIGIL_PREFS_DIR`    | Full path to override Sigil user preferences location (Should align with the config mount)|
| `SIGIL_EXTRA_ROOT`   | Path for relocated Sigil support files |
| `SIGIL_DICTIONARIES` | Colon-separated list of dictionary search paths |

### Volume Mappings (`-v`)

| Volume | Function |
| :----: | --- |
| `/home/abc/.local/share/sigil-ebook` | Sigils config Directory storing the preferences and configs |

#### Miscellaneous Options

| Parameter | Function |
| :-----:   | --- |
| `--security-opt seccomp=unconfined` | For Docker Engine only, many modern gui apps need this to function on older hosts as syscalls are unknown to Docker. |

## Environment variables from files (Docker secrets)

You can set any environment variable from a file by using a special prepend `FILE__`.

As an example:

```bash
-e FILE__MYVAR=/run/secrets/mysecretvariable
```

Will set the environment variable `MYVAR` based on the contents of the `/run/secrets/mysecretvariable` file.

## Umask for running applications

For all of our images we provide the ability to override the default umask settings for services started within the containers using the optional `-e UMASK=022` setting.
Keep in mind umask is not chmod it subtracts from permissions based on it's value it does not add. Please read up [here](https://en.wikipedia.org/wiki/Umask) before asking for support.

## User / Group Identifiers

When using volumes (`-v` flags), permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id your_user` as below:

```bash
id your_user
```

Example output:

```text
uid=1000(your_user) gid=1000(your_user) groups=1000(your_user)
```

---

## Support Info

* Shell access whilst the container is running:

    ```bash
    docker exec -it sigil /bin/bash
    ```

* To monitor the logs of the container in realtime:

    ```bash
    docker logs -f sigil
    ```

* Container version number:

    ```bash
    docker inspect -f '{{ index .Config.Labels "build_version" }}' sigil
    ```

* Image version number:

    ```bash
    docker inspect -f '{{ index .Config.Labels "build_version" }}' ghcr.io/thecfu/sigil-docker:latest

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:

```bash
git clone https://github.com/thecfu/sigil-docker.git
cd sigil-docker
docker build \
  --no-cache \
  --pull \
  -t ghcr.io/thecfu/sigil-docker:latest .
```

---

## Credits

- [Sigil-ebook](https://sigil-ebook.com/)
- [LinuxServer.io Base Image](https://github.com/linuxserver/docker-baseimage-kasmvnc)
- [LinuxServer.io](https://linuxserver.io)


## License
This Project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

```
___________.__           _________   _____ ____ ___ 
\__    ___/|  |__   ____ \_   ___ \_/ ____\    |   \
  |    |   |  |  \_/ __ \/    \  \/\   __\|    |   /
  |    |   |   Y  \  ___/\     \____|  |  |    |  / 
  |____|   |___|  /\___  >\______  /|__|  |______/  
                \/     \/        \/                 
```
