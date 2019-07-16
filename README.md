# Dockerized Firefox ESR [![Linux Build Status](https://img.shields.io/travis/phlummox/docker-firefox-esr.svg?label=Linux%20build)](https://travis-ci.org/phlummox/docker-firefox-esr)&nbsp;[![Docker stars](https://img.shields.io/docker/stars/phlummox/carnap-test.svg?label=Docker%20stars)](https://cloud.docker.com/repository/docker/phlummox/firefox-esr) 

Because I just hate the way web browsers insert themselves into your
OS. And how much of a pig Chromium-based browsers are. And how broken
Midori is at the moment.

Using Firefox in a Docker container, you can decide exactly how much of the
rest of your system your browser can see.

Keeping the browser updated is more of a pain, because you have
to rebuild the image you're using, but at least it won't happen
without your knowing.

## Usage

If you're willing to expose your X Window system and network to the browser,
you could do something like the following (assuming you're on a Debian/Ubuntu
host):

```
$ xhost + 
$ docker run --rm -it -e DISPLAY --net=host \
  phlummox/firefox-esr:0.1 firefox
```

-   Visit `about:config`, agree to condition, search for
    `browser.tabs.remote.autostart`, click on it to set it to "false".

The above will work for a bit for basic sites. But Firefox's use of sockets
(and possibly threads?) apparently doesn't play well with Docker's default
containment policy, and it'll [crash after a while][crash]. To fix this properly,
you'd want to find out [exactly what syscalls Firefox is making][syscalls], and decide
what you want to allow, and [write your own seccomp profile][secprofile] to
allow just those. Which you could do of course. And you might have to do
something similar for Docker's default [AppArmor profile][apparmor].

[crash]: https://github.com/SeleniumHQ/docker-selenium/issues/397
[syscalls]: https://firejail.wordpress.com/documentation-2/seccomp-guide/ 
[secprofile]: https://docs.docker.com/engine/security/seccomp/
[apparmor]: https://docs.docker.com/engine/security/apparmor/


If you're happy to grant the container a few more privileges -- it can make
any syscall, subject to the usual user permissions -- you could try

```
$ xhost + 
$ docker run --rm -it -e DISPLAY --net=host \
  --security-opt seccomp:unconfined \
  phlummox/firefox-esr:0.1 firefox
``` 

This should work fine -- no crashing so far as I can see, videos will play,
but the browser seems to have no access to the host sound system. (Quite possibly
a feature, rather than a bug, if you ask me.)

And if you really want, you can give the browser access to the host 
[D-Bus](https://en.wikipedia.org/wiki/D-Bus) and your X Window Unix
domain socket, and remove AppArmor restrictions:

```
$ docker run --rm -it -e DISPLAY --net=host \
  --security-opt seccomp:unconfined \
  --security-opt apparmor:unconfined \
  -v /var/run/dbus:/var/run/dbus -e DBUS_SESSION_BUS_ADDRESS \
  -v /run/user/1001:/run/user/1001 \
  -v /run/dbus/system_bus_socket:/run/dbus/system_bus_socket \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  phlummox/firefox-esr:0.1 firefox   
```

(Assuming you have user ID 1001 on your system. Which I do.) Again, do the
needful with the `about:config` page -- that goes for all these examples.
No sound, but seems to be crash-free.

If you are happy to give the browser the same access to your
[GPU][gpu] as any other app, you can add `--device /dev/dri/`. But if you want to
enable sound, you'll have to do more work, or you could check out 
Jess Frazelle's work on dockerizing Firefox, at
<https://github.com/jessfraz/dockerfiles/tree/master/firefox>.

[gpu]: https://en.wikipedia.org/wiki/Direct_Rendering_Manager

Anyway, if you *really* wanted your browser to be secure, you'd probably
run it from inside a VM. Or only use text-based browsers. Or go the Richard
Stallman route, and have a bot [email you the HTML of web pages you want][rms]
so you can view them locally.

[rms]: https://stallman.org/stallman-computing.html

But if you want things to be a *bit* more convenient, maybe this image will
help.




