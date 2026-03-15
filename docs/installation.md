# Bootstrapping FCOS and k0s

## Links

### Official Docs
Butane: https://coreos.github.io/butane/
Zincati: https://coreos.github.io/zincati/
k0s Install: https://docs.k0sproject.io/v1.21.2+k0s.1/install/
k0s Multi-Node Install: https://docs.k0sproject.io/head/k0s-multi-node/
Producing .ign config: https://docs.fedoraproject.org/en-US/fedora-coreos/producing-ign/
FCOS Bare Metal Install: https://docs.fedoraproject.org/en-US/fedora-coreos/bare-metal/

### Community Resources
Beginner's Guide to FCOS: https://www.reddit.com/r/Fedora/comments/1i7ewsf/beginners_guide_to_fedora_coreos/
Youtube video on .gu -> .ign: https://www.youtube.com/watch?v=o5TTbA3YaHQ&t=310s


## Considerations
- This is a 3-node system for now so all the nodes will inherit both
roles of controller/worker. This satisfies the requirement of HA.
- These steps were created while on a mac. You might have to adjust
some of the manual commands to match your OS (e.g. Windows). 

## Limitations
- I'm on my apartment WiFi, I don't have direct control of DHCP. I guess I'm double NAT'd?
- The 3-node consideration creates a limitation in bootstrapping >1
infra nodes. This is because etc.d requires a quorum and during bootstrap
a second stage iso installation is needed to flash the iso to the node's
drive. More on this in the steps section.
- The steps use a physical thumb drive for ISO installation. There are
better alternative methods via iPXE and whatnot but that's beyond the scope
of this installation.

## Prereqs
- [ ] Docker/Podman image for butane: quay.io/coreos/butane:release
- [ ] Docker/Podman image CoreOS installer: quay.io/coreos/coreos-installer

## Steps

### Bootstrap the primary controller node (node0-boot-controller)
This step needs to be done in isolation because we will generate the
join tokens for the cluster and stored locally. The butane files for
the following nodes will need to be able to resolve these tokens later.

*Run the following commands from the project's root dir*

- [ ] Plug in the USB you intend to flash images on

0. We are running headless and we get SSH decalratively. Be sure to edit
the `ssh_authorized_keys_local:` field to match the path of the
workstations public ssh key you wish to use.

1. Let's start with generating the node0 butane file into a igntion file.

`./infra/scripts/generate-ignition.sh infra/butane/node0-boot-controller.bu`
you should see that the igntion was create.

2. Let's embed the .ign file into the base FCOS iso
*NOTE: You should have installed the base FCOS image somewhere*
Alter the ISO_SRC variable in `embed-ignition.sh` script to reflect that
location. For example my path is `ISO_SRC="${HOME}/Downloads/fedora-coreos-43.***`.

`./infra/scripts/embed-igntion.sh infra/ignition/node0-boot-controller.ign`

Now you should have an ISO in the iso's folder in the project root dir.

3. Let's flash that ISO onto the USB drive.
`sudo dd if=./infra/isos/fcos-node0-boot-controller.iso of=/dev/rdisk5 bs=4m status=progress`
*NOTE: The location of your thumb drive might be different*

4. Bootstrap your node and spam the sh-t out of f12. Take note of the IP
`ssh core@<node0-IP>` this should drop you in as *core* user.

5. We need to flash the ISO to the drive with something like the follwing
command.
`sudo coreos-installer install /dev/sda --ignition-file /run/ignition.json`
*NOTE: Your primary drive might be different*
Once that completes run `sudo reboot`. Now you can remove the drive. 

6. Your node0 should now be up and running
Let's verify a few things on the node0. We need to regen the key
`ssh-keygen -R <node0-IP>` and then `ssh core@<node0-IP>`.

`sudo k0s status`
```
Role: controller
Workloads: true
SingleNode: false
```

`sudo k0s kubectl get nodes`
```
NAME        STATUS   ROLES           AGE     VERSION
hl-node-0   Ready    control-plane   2m33s   v1.35.1+k0s
```
`sudo k0s kubectl get pods -A`

Once we've confirmed healthy state we can remove and peripherals, and
just let the node be. *Do not disturb this node any further*.

7. Take note of the controller and worker join tokens and place them in
the .envs directory under the infra folder.

`ssh core@<node0-IP> "sudo cat /var/lib/k0s/tokens/controller-token" > infra/.env/controller-token`
`ssh core@<node0-IP> "sudo cat /var/lib/k0s/tokens/worker-token" > infra/.env/worker-token`

### Bootstrap the supporting controller noded (further nodes)
Now that we've setup the bootstrap controller, let's move on to the
other controller nodes. It's worth noting that we are operating in a HA
system, meaning all our initial nodes will serve as both control plane
and worker nodes. This ends up being a bit scary because etc.d requires
a quorum and if we mess up the boot process or if a node goes down during
the join process the control plane can get in a stuck state. If this occurs
we have to restart the entire process over. This has happened to me a few
times trying to figure out the right butane configs and boot order/process.

With that in mind let's setup the supporting controller nodes.

*NOTE: The process will be the same for all proceeding nodes just replace #'s*

0. Generate .ign file for new node from butane file.
`./infra/scripts/generate-ignition.sh infra/butane/node1-base.bu`

1. Embed .ign file into the iso.
`./infra/scripts/embed-igntion.sh infra/ignition/node1-base.ign`

2. Flash the iso onto the thumb drive.
`sudo dd if=./infra/isos/fcos-node1-base.iso of=/dev/rdisk5 bs=4m status=progress`

3. Take note of the IP address of the node and ssh to it.

4. Bootstrap the next node with the ISO.
While still in boot mode let's verify that our token exists in the path
`sudo cat /var/lib/k0s/tokens/controller-token`
and that the install script *EXISTS*
`sudo cat /usr/local/bin/bootstrap-k0s-controller.sh` do *NOT* run anything yet.

It is paramount we dont do anything kube related here.

5. Flash the iso onto the host's drive and reboot.
`sudo coreos-installer install /dev/sda --ignition-file /run/ignition.json`

6. Reboot the node and remove the thumb drive.
`sudo reboot`

7. Get back to the shell
`ssh-keygen -R <node-ip>`
`ssh core@<node-ip>`

8. Run and verify the k0s install join script.
`sudo bash /usr/local/bin/bootstrap-k0s-controller.sh`

It might take some time to get stuff going.

`sudo k0s kubectl get nodes`
```
core@hl-node-1:~$ sudo k0s kubectl get nodes
NAME        STATUS   ROLES           AGE   VERSION
hl-node-0   Ready    control-plane   55m   v1.35.1+k0s
hl-node-1   Ready    control-plane   90s   v1.35.1+k0s
```

9. Do the same for the rest of the nodes, you want in your control plane.

Here's the working control plane that's HA with quorum rules floor(n/2) + 1
One fails and things still run smoothly.

```
core@hl-node-0:~$ sudo k0s kubectl get nodes
NAME        STATUS   ROLES           AGE   VERSION
hl-node-0   Ready    control-plane   74m   v1.35.1+k0s
hl-node-1   Ready    control-plane   19m   v1.35.1+k0s
hl-node-2   Ready    control-plane   58s   v1.35.1+k0s
```

### Use kubectl outside the cluster

0. Install kubectl
`brew install kubectl`

1. Copy pki over to config
Under `~/.kube/config` copy over the contents of `sudo cat /var/lib/k0s/pki/admin.conf`
from a control plane node.

Worker nodes ... tbd
