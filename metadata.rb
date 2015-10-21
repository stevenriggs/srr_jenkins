name             'srr_jenkins'
maintainer       'Steven Riggs'
maintainer_email 'steven.riggs@icloud.com'
license          'All rights reserved'
description      'Installs/Configures srr_jenkins'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.2'

depends 'srr_iptables'
depends 'srr_jdk'
depends 'srr_deploy'
