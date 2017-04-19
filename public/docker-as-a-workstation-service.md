# Docker as a (workstation) service

[Docker](http://docker.com) promotes itself as
"a tool for developers and sysadmins to build, ship, and run distributed applications,"
and there is much literature available to describe workflows to that end.
I primarily use it for a much different purpose: to simplify my workstation setup.


## What Docker is

First things first, Docker is two things: a company and a collection of open-source tools maintained by said company.
I will primarily be speaking of the latter, specifically [Docker Engine](https://docs.docker.com/engine/reference/run/).

For the purpose of this post, I will make drastic simplifications in my explanation,
but the Docker site itself has very good documentation if you are keen to explore further.
It is safe to think of Docker as a lightweight, single-purpose virtual machine.
Being a virtual machine, anything you run inside of Docker is isolated from the host.
The single-purpose bit is also important, though.
Here is how I understand the philosophy behind Docker images:

> What is the bare minimum I need in order to run this program on Linux?

A Docker image should include those things and nothing else.

In Docker-land, an **image** is the saved state of the program.
Images **layer** on top of each other, which means Docker works much like `git`.
When a series of layers combines to make a meaningful image, we use a **tag** to name it.
Once we are actually running the program (defined by the image), we call it a **container**.


## When I use it

Every time we want to write software on our computers, we need to set up an environment.
Sometimes, this is just an expected inconvenience.
When we spend long periods of time on one project, it is often helpful to understand the setup process.
Many times, however, I just want to play with a new language, try out a popular framework, or run a toy project.
Knowing that I might have to spend hours with project setup can be a deterrence.

This is where Docker helps me out!
Thanks to the breadth of Docker's centralized repository for images,
I can create isolated, virtual workstations as quickly as my Internet connection will allow.


## How I use it

OK, imagine we want to use Java 8 without installing it on our machine.
To start, I usually navigate to [hub.docker.com](http://hub.docker.com) and search for the container I need.
If you prefer to stay in the command-line, you can do the same with `docker search java`.
Here is the description of the first one:

> Java is a concurrent, class-based, and object-oriented programming language.

Sounds pretty good!
One thing to keep in mind is that "official repositories" are nested under [`/_/`](https://hub.docker.com/explore/),
so when you see that path prefix, it is a safe bet.
So now, we will use it.

```
$ docker run --rm java:8 java -version
Unable to find image 'java:8' locally
8: Pulling from library/java
Digest: sha256:2b840b021b8753dd18da3491d362999980e6636b4a3064ff57bf17ea6dbce42f
Status: Downloaded newer image for java:8
openjdk version "1.8.0_91"
OpenJDK Runtime Environment (build 1.8.0_91-8u91-b14-1~bpo8+1-b14)
OpenJDK 64-Bit Server VM (build 25.91-b14, mixed mode)
```

That's it! Here is what happened:

 0. Docker downloaded the layers required to construct the image tagged `java:8`
 0. Docker started a container (from that image) and ran `java -version` inside it
 0. Docker stopped the container and deleted it courtesy of the `--rm` flag

Here is the great part: assuming Docker is already installed on your machine,
you have not had to install any dependencies!
Docker will cache the downloaded images so that you don't have to pull them every time,
but there is no lingering system-level confiuration or state.
And zero configuration time... or so I claim, at least.

You should be thinking to yourself, "Printing out a version is great, but how do I use it for real?"
Now imagine we want to contribute to a cool open-source project in a cool open-source language.
Here is how we might get said project up and running in two lines without installing anything:

```
$ git pull git@github.com:robjertjlooby/elm-koans.git
$ docker run -p 8000:8000 -v $PWD/elm-koans:/app -w /app codesimple/elm:0.17 reactor --address 0.0.0.0
Listening on http://0.0.0.0:8000/
```

Just use your favorite browser to visit `localhost:8000` to see the app running.
The command-line options here are a bit more complex than our last example, but there is no magic.
Here is a list of options I find myself most commonly using:

 - **-p, --publish value** – publish a container's port(s) to the host (default [])
 - **-v, --volume value** – mount a directory from host (default [])
 - **-w, --workdir string** – working directory inside the container
 - **-d, --detach** – run container in background and print container ID
 - **-i, --interactive** – keep STDIN open even if not attached
 - **-t, --tty** – allocate a pseudo-TTY
 - **--rm** – automatically remove the container when it exits

I included the power couple, `-it` in that list without giving a formal introduction.
They can be used together to replicate a normal shell experience, like so:

```
$ docker run -it swiftdocker/swift bash
root@69a9799172fb:/app# mkdir -p src/Testing
root@69a9799172fb:/app# echo 'print("just like a normal shell")' > src/Testing/main.swift
root@69a9799172fb:/app# touch Package.swift
root@69a9799172fb:/app# swift build
Compile Swift Module 'Testing' (1 sources)
Linking .build/debug/Testing
root@69a9799172fb:/app# .build/debug/Testing
just like a normal shell
```

I just created, compiled, and ran a Swift project in seconds without installing a thing!


## What else can you do

Please consider this a brief introduction.
If you want to really see the Docker-as-a-workstation-tool idea in action,
please checkout [this awesome post](https://blog.jessfraz.com/post/docker-containers-on-the-desktop/) by Jessie Frazelle.
Also, if you are interested in running multiple containers that communicate with each other,
I recommend exploring [`docker-compose`](https://docs.docker.com/compose/).

For me, seeing Docker as a tool for workstation isolation significantly lowered the barrier to entry
for project ramp-up and open-source contribution.
May it do likewise for you.
Happy `docker run`-ing!


_Jul 27, 2016_
