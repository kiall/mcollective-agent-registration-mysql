# MySQL MCollective Registration Agent

## Intro

This is a simple mysql registration agent for mcollective.

## Sample Schema

	CREATE TABLE IF NOT EXISTS `registration` (
	  `id` int(255) unsigned NOT NULL AUTO_INCREMENT,
	  `fqdn` varchar(255) NOT NULL,
	  `classes` varchar(255) NOT NULL,
	  `yaml` text,
	  `lastseen` int(10) unsigned NOT NULL,
	  PRIMARY KEY (`id`)
	) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

## Debian Packages

### Apt Repo

> Warning! We have other mcollective .deb's in that repo.

	$ wget -q -O - http://apt.managedit.ie/public.key | sudo apt-key add -
	$ sudo apt-add-repository 'deb http://apt.managedit.ie/ mcollective master'
	$ sudo apt-get install mcollective-agent-registration-mysql

### Downloads

> Development .deb's are automatically built on each commit.

* Stable - http://apt.managedit.ie/pool/master/m/mcollective-agent-registration-mysql/
* Development - http://apt.managedit.ie/pool/develop/m/mcollective-agent-registration-mysql/
