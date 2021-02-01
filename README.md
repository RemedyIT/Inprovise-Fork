
Inprovise Fork
==============

This project implements an extension for the Inprovise provisioning tool providing a `fork` method to the execution contexts
of Inprovise scripts allowing scripts to fork off provisioning commands (`apply`, `revert`, `validate` or `trigger`) for
other nodes.

[![Build Status](https://travis-ci.org/mcorino/Inprovise-Fork.png)](https://travis-ci.org/mcorino/Inprovise-Fork)
[![Code Climate](https://codeclimate.com/github/RemedyIT/Inprovise-Fork/badges/gpa.png)](https://codeclimate.com/github/RemedyIT/Inprovise-Fork)
[![Test Coverage](https://codeclimate.com/github/RemedyIT/Inprovise-Fork/badges/coverage.png)](https://codeclimate.com/github/RemedyIT/Inprovise-Fork/coverage)
[![Gem Version](https://badge.fury.io/rb/inprovise-fork.png)](https://badge.fury.io/rb/inprovise-fork)

Installation
------------

    $ gem install inprovise-fork

Usage
-----

Add the following to (for example) your Inprovise project's `rigrc` file.

````ruby
require 'inprovise/fork'
````

Syntax
------

````ruby
fork(mode = :sync).apply('script', 'name'[, 'name'[, ...]][, config={}])
fork(mode = :sync).revert('script', 'name'[, 'name'[, ...]][, config={}])
fork(mode = :sync).validate('script', 'name'[, 'name'[, ...]][, config={}])
fork(mode = :sync).trigger('action', 'name'[, 'name'[, ...]][, config={}])
````

or

````ruby
fork(mode = :sync) do
  apply('script', 'name'[, 'name'[, ...]][, config={}])
end
fork(mode = :sync) do
  revert('script', 'name'[, 'name'[, ...]][, config={}])
end
fork(mode = :sync) do
  validate('script', 'name'[, 'name'[, ...]][, config={}])
end
fork(mode = :sync) do
  trigger('action', 'name'[, 'name'[, ...]][, config={}])
end
````

The `mode` argument can be `:sync` (default) or `:async`. With the first the provisioning methods will not return
until the provisioning process they kicked off has finished. With the latter the provisioning methods kick off the
provisioning process in parallel and return immediately.

The provisioning methods return a reference to the forking execution context allowing provisioning methods to be
chained like:

````ruby
fork.apply('script', 'node1').trigger('action', 'node1')

````

Example
-------

By combining the [Inprovise-VBox](https://github.com/mcorino/Inprovise-VBox) plugin and the [Inprovise-Fork](https://github.com/mcorino/Inprovise-Fork) plugin
provisioning scripts could add a virtual machine on a host server, register an Inprovise node and provision that new node with a single
`rig` command using a scheme like this:

````ruby
# assumes rigrc has been defined with
# require 'inprovise/vbox' and
# require 'inprovise/fork'

include 'rubysetup.rb'  # includes a scheme defining scripts to control ruby provisioning dependencies

script 'vmSetup' do

  validate do
    # check node setup
    trigger 'gem:exists', 'rails'
  end

  apply do
    trigger 'gem:install', 'rails'
  end

  revert do
    trigger 'gem:uninstall', 'rails'
  end

end


vbox 'myVM' do
    configuration ({
      :name => 'MyVM',
      :image => '/remote/image/path/MyVM.qcow2',
      :memory => 1024,
      :cpus => 2
    })

    apply do
      fork(:async).apply('vmSetup', 'MyVM')
    end

    revert do
      # in real life you may not want to do this to be able to reinstate
      # the VM faster with all setup already in place
      fork(:sync).revert('vmSetup', 'MyVM')
    end
end

end

````
