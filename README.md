![ALM Reports](https://cloud.githubusercontent.com/assets/238667/4099964/4ae98d6e-3078-11e4-9c59-8909a01029c4.png)
alm-report
==========

[![Build Status](https://magnum.travis-ci.com/articlemetrics/alm-report.svg?token=KamPjZmu9WPvmWcXwBRx&branch=master)](https://magnum.travis-ci.com/articlemetrics/alm-report)

## How to start developing now?

`ALM Reports` uses [Vagrant](https://www.vagrantup.com/) and [Virtualbox](https://www.virtualbox.org/) for setting up the development environment. To start developing now on your local machine (Mac OS X, Linux or Windows):

1. Install Vagrant: https://www.vagrantup.com/downloads.html
1. Install Virtualbox: https://www.virtualbox.org/wiki/Downloads
2. Clone this repository `git clone git@github.com:articlemetrics/alm-report.git`
3. Cd into it and run `vagrant up`

Once the setup is complete (it might take up to 20 minutes), you'll be able to open up a browser and navigate to [http://10.2.2.2](http://10.2.2.2), and you should see this screen:

![ALM Reports screenshot](https://cloud.githubusercontent.com/assets/238667/4106614/fba19bee-31bb-11e4-9467-214488da6ece.png)


## Developing using AWS/EC2

You can also use a VM from AWS/EC2 to develop on, by first setting the relevant AWS credentials in `Vagrantfile`:

```
  aws.access_key_id = "EXAMPLE"
  aws.secret_access_key = "EXAMPLE"
  aws.keypair_name = "EXAMPLE"
  aws.security_groups = ["EXAMPLE"]
  override.ssh.private_key_path = "~/path/to/ec2/key.pem"
```

And then specifying the `aws`provider:

```
vagrant up --provider=aws
```

## Documentation

Detailed instructions on how to start developing are [here](https://github.com/articlemetrics/alm-report/blob/master/docs/development.md).
When you're ready to deploy `ALM Reports`, take a look at the [in-depth deployment guide](https://github.com/articlemetrics/alm-report/blob/master/docs/development.md).

In case you would like to setup the dependencies manually (for example for non-Vagrant local development, or for servers not provisioned with Chef), check out the [manual installation guide](https://github.com/articlemetrics/alm-report/blob/master/docs/manual_installation.md).
