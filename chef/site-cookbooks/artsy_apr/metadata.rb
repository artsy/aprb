name             'artsy_apr'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures artsy_apr'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends          'artsy_base', '= 0.1.3'
depends          'aws', '= 3.3.2'
depends          'nodejs', '= 2.4.4'
depends          'citadel'
