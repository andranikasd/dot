#!/bin/bash

# Create a directory for the test Vagrant project
mkdir test_vagrant_project
cd test_vagrant_project

# Initialize Vagrant
vagrant init

# Add a box to the Vagrantfile (you may need to replace 'ubuntu/focal64' with a box of your choice)
echo 'Vagrant.configure("2") do |config|' >> Vagrantfile
echo '  config.vm.box = "ubuntu/focal64"' >> Vagrantfile
echo 'end' >> Vagrantfile

# Start the Vagrant virtual machine
vagrant up

# SSH into the virtual machine
vagrant ssh -c 'echo "Hello from Vagrant!"'
