# How to run GUI applications in Docker container

Do just

```
make run
```

Inspecting [`Dockerfile`](Dockerfile), you can see there is not anything special,
`x11-apps` are installed just to have `xclock` available to test this method. All
magic is in the [`Makefile`](Makefile) `run` target.

## Allowing Docker to communicate with X11 server and related security risks

The `xhost +local:docker` command is used to allow Docker containers to communicate
with the X server on the host machine.

`xhost` is a command-line utility for managing the list of hostnames or user names
that are allowed to make connections to the X server. By executing `xhost +local:docker`,
you're allowing any local user to make connections to the X server.

As for the security concern, this is because the `xhost +` command (without any
specifications) can allow any user from any host to connect to the X server, and
they can then do anything they like with the GUI, including simulating keyboard
and mouse events. This is obviously a huge security risk if your system is
connected to any kind of network.

`xhost +local:docker` is a bit safer because it only allows local connections
from Docker, but it still means that any Docker container you run has full access 
to your screen, keyboard, and mouse, which might still be a security risk.
For example, it could potentially capture keystrokes or screenshots without your knowledge.

A better approach would be to use a method that allows only specific Docker containers
to access the X server, or to use a virtual X server for Docker that is separate from
your main X server. Docker has built-in methods for isolating applications, and it
would be better to use those than to punch a hole in your security with xhost.

We are enabling the access and disabling it immediately after the container terminates.

Sharing the `.Xauthority` file with the container does help improve security by ensuring
that only containers with access to the correct X11 authentication token can connect
to the X server. However, since the Docker container has access to the file, a malicious
container could potentially read the X11 authentication token and use it even after
`xhost - local:docker` has been run, if the token hasn't been changed.

While these methods do reduce the risks, they don't eliminate them entirely. If you're
working in a high-security environment or dealing with sensitive data, it might be better
to use more isolated methods for running GUI applications in Docker, such as using
a separate, virtual X server just for Docker.

## Running the container

The Docker run command includes a few parameters that are configuring how the container
will interact with your host system. Here's what each of them do:

1. `-v ${HOME}/.Xauthority:/root/.Xauthority:rw` : This flag is used to mount a volume
from the host system into the Docker container. Here, it's used to share the X11
authentication token between the host system and the Docker container. The `.Xauthority`
file is a crucial part of X11 security, it stores credentials in a cookie format used
for authentication of X11 sessions. By sharing this file, you're allowing the Docker
container to authenticate with the host's X server.

2. `-e DISPLAY` : This flag is used to pass environment variables from the host system
into the Docker container. In this case, it's passing the `DISPLAY` environment variable,
which tells X11 clients (like your Docker container) which X11 server to connect to.
It usually points to a local X11 server.

3. `--net=host`: This flag is used to make the networking environment inside the Docker
container the same as the host system. Essentially, the Docker container will share the
host's network stack and all interfaces from the host will be available to the container.
This is necessary for the container to be able to communicate with the X server, which
is running on the host.

While this setup allows the containerized application to access the host's X server for
GUI functionality, it should be noted that there are potential security implications,
as this does give the container greater access to the host system than is usually
desirable for a containerized application. Depending on the nature of the application
and the network environment, a more isolated setup might be preferable.
