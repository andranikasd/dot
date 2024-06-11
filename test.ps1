# Create a directory for the test Vagrant project
New-Item -ItemType Directory -Name test_vagrant_project
cd test_vagrant_project

# Initialize Vagrant
vagrant init

# Add a box to the Vagrantfile (you may need to replace 'ubuntu/focal64' with a box of your choice)
Add-Content -Path Vagrantfile -Value 'Vagrant.configure("2") do |config|'
Add-Content -Path Vagrantfile -Value '  config.vm.box = "ubuntu/focal64"'
Add-Content -Path Vagrantfile -Value 'end'

# Start the Vagrant virtual machine
vagrant up

# SSH into the virtual machine and print a message
vagrant ssh -c 'echo "Hello from Vagrant!"'

# Destroy the virtual machine
vagrant destroy -f

# Clean up
cd ..
Remove-Item -Path test_vagrant_project -Recurse
