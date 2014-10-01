Exec { path => [ "/usr/local/sbin/", "/usr/local/bin/" , "/usr/sbin/", "/sbin/", "/usr/bin", "/bin/" ] }

define append_if_no_such_line($file, $line, $refreshonly = 'false') {
   exec { "/bin/echo '$line' >> '$file'":
      unless      => "/bin/grep -Fxqe '$line' '$file'",
      path        => "/bin",
      refreshonly => $refreshonly,
   }
}

class must-have {
  include apt
  apt::ppa { "ppa:webupd8team/java": }

  exec { 'apt-get update':
    command => '/usr/bin/apt-get update',
    before => Apt::Ppa["ppa:webupd8team/java"],
  }

  exec { 'apt-get update 2':
    command => '/usr/bin/apt-get update',
    require => [ Apt::Ppa["ppa:webupd8team/java"], Package["git-core"] ],
  }

  package { ["vim",
             "curl",
             "git-core",
             "bash",
             "subversion"]:
    ensure => present,
    require => Exec["apt-get update"],
    before => Apt::Ppa["ppa:webupd8team/java"],
  }

  package { ["oracle-java7-installer"]:
    ensure => present,
    require => Exec["apt-get update 2"],
  }

  apt::source { 'docker':
        location => "http://get.docker.io/ubuntu",
        key => "A88D21E9",
        release => "docker",
        repos => "main",
        include_src => false
    }

  exec { 'apt-get update 3':
    command => '/usr/bin/apt-get update',
    require => [ Apt::Source['docker'] ]
  }

  package { 'raring-kernel':
        name => 'linux-image-generic-lts-raring',
        ensure => present,
        require => Exec["apt-get update 3"],
    }

  package { 'lxc-docker':
        require => Package["raring-kernel"]
    }

  exec {
    "accept_java_license":
    command => "echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections && echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections",
    cwd => "/home/vagrant",
    user => "vagrant",
    path    => "/usr/bin/:/bin/",
    require => Package["curl"],
    before => Package["oracle-java7-installer"],
    logoutput => true,
  }

  append_if_no_such_line { motd:
    file => "/etc/motd",
    line => "This is a java/Docker/fig VM meant to run the docker-sling-cluster playground"
  }

  # install fig via curl  
  $figversion = "0.5.2"
  $versionfile = "/var/log/puppet/fig.version"

  exec { "install-fig":
    command => "curl -s -L -o /usr/local/bin/fig https://github.com/docker/fig/releases/download/${figversion}/linux  \
                && chmod o+x /usr/local/bin/fig \
                && echo \"$figversion\" > \"$versionfile\"",
    unless  => "test \"`cat $versionfile 2>/dev/null`\" = \"$figversion\""
  }
}

include must-have
