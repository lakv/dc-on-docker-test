# DC on Docker with [OpenSwitch](http://www.openswitch.net)
### Based on the work of [keinohguchi](https://github.com/keinohguchi/dc-on-docker) and [davrodpin](https://github.com/davrodpin/dc-on-docker) with some usability tweaks and inexplicable stability improvements.

Creating your own data-center (DC) on your laptop with Ansible and
Docker-Compose in a snap!

Here is [dc-on-docker in action](https://asciinema.org/a/44142),
which is the step-by-step screen cast how to create
[dc-on-docker](https://github.com/keinohguchi/dc-on-docker)
on your laptop with [vagrant](http://vagrantup.com),
[docker](http://docker.com), and [OpenSwitch](http://openswitch.net).

## Requirements

- Ansible 2.1 and above, because OpenSwitch ansible roles, e.g. [ops switch role](http://github.com/keinohguchi/ops-switch-role), depends on Ansible 2.1 modules.
- Vagrant from www.vagrantup.com, not your distro's repos.

### Using Vagrant

You can use [vagrant](http://vagrantup.com) to create a sandboxed Ansible
control machine, if you want to test it out, though this is actually not
a requirement.  But if you do, here is some tips to set the vagrant
environment up.

#### Proxy setup

If you're behind a proxy, make sure you have `http_proxy` and `https_proxy`
available as environment variables if you are under a web proxy;

* On Windows

```
set http_proxy=%WEB_PROXY_URL%
set https_proxy=%WEB_PROXY_URL%
```

* On Linux or OSX

```
export http_proxy=$WEB_PROXY_URL
export https_proxy=$WEB_PROXY_URL
```

#### Virtualbox

Download and install Virtualbox 5.0.16 from [virtualbox.org](https://www.virtualbox.org/wiki/Downloads);

#### Vagrant

Download and install Vagrant 1.8.1 from [vagrantup.com](https://releases.hashicorp.com/vagrant/1.8.1);

Optionally, you can install required vagrant plugins:

```
$ vagrant plugin install vagrant-proxyconf vagrant-vbguest
```

#### Useful commands

Create the virtual machine:

```
$ vagrant up
```

Accessing the virtual machine:

```
$ vagrant ssh
```

## Topology

```

                           |1
                        +--+---+
                        | fab1 |
                        ++---+-+
                         |2  |3
                    +----+   +----+
                    |1            |1
                +---+----+   +----+---+
                | spine1 |   | spine2 |
                ++--+--+-+   +-+--+--++
                 |2 |3 |4      |2 |3 |4
          +------+  |  |       |  |  +------+
          |         |  +-------|--|-----+   |
          |   +-----|----------+  |     |   |
          |   |     |             |     |   |
          |   |     +----+   +----+     |   |
          |1  |2         |1  |2         |1  |2
        +-+---+-+      +-+---+-+      +-+---+-+
        | leaf1 |      | leaf2 |      | leaf3 |
        +---+---+      +---+---+      +---+---+
            |3             |3             |3

```

## Setup

### Setup Topology

Single playbook to setup the above topology.  It's basically
It's primarily the `docker-compose` with the new `docker networking`
stuff, with additional tweaks for OpenSwitch interfaces:

```
  $ ansible-playbook utils/setup.yaml
```

#### Smaller set of topology

```
  $ ansible-playbook --limit fabrics:docker --extra-vars "docker_compose_file=docker-compose1.yaml docker_network_script=docker-network1.sh" utils/setup.yaml
```

After this, you can run the test file, say `tests/test_switch.yml`, as below:

```
  $ ansible-playbook tests/test_switch.yml
```

### Switch health

You can check the switch reachability by running the `utils/ping.yaml`
playbook, as below:

```
  $ ansible-playbook utils/ping.yaml
```

## Play

Now, you're ready for play, and of course, it's called `site.yaml`:

```
  $ ansible-playbook --skip-tags bgp site.yaml
```

We need to skip the `bgp` related plays at this point as there is
an issue on [OpenSwitch bgp role](https://github.com/keinohguchi/ops-bgp-role).

### Specific play

You can only run the specific host by using the `--limit` option
as below:

```
  $ ansible-playbook --limit fabrics --skip-tags bgp site.yaml
```

for example, to run only the basic L2/L3 plays against the
[fabric switches](hosts).

### Test

You can run the test locally as simple as one liner.  We embrace the
TDD philosophy here, too.

```
  $ ansible-playbook tests/test_bridge.yml
```

## Tear down

Teardown the topology, after the party.

```
  $ ansible-playbook utils/teardown.yaml
```

## Screenshot

Here is the [screenshot](https://gist.github.com/keinohguchi/fa22e11f65489ac6ad94707960a26c26)
of the `ansible-playbook site.yaml` for your reference.

Enjoy and happy hacking!
