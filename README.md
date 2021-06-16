# DeBounce.io  Email Validaton for Exim
Check outgoing email sent with Exim, the checks are performed with the DeBounce API.

Please consider limit rate:
The maximum number of concurrent calls (parallel connections) is 10. If you validate emails with a higher speed, you will get an error



## Installation

Modified files:
/etc/exim.acl_check_recipient.pre.conf
/etc/exim.acl_script.pre.conf
/etc/exim.custom.pl
/etc/exim.routers.pre.conf


API key is saved in:

/etc/exim.custom.pl:
my $url = "https://api.debounce.io/v1/?api=&email=".$recipient;

/etc/exim.custom.test.pl
my $url = "https://api.debounce.io/v1/?api=&email=".$email;




## Disable DeBounce Email Validation
Should you want to disable the customization rename the files:

/etc/exim.acl_check_recipient.pre.conf

/etc/exim.acl_script.pre.conf

/etc/exim.custom.pl

to

/etc/exim.acl_check_recipient.pre.conf.OFF

/etc/exim.acl_script.pre.conf.OFF

/etc/exim.custom.pl.OFF



## Add email adresses to the allow list
A skip file can be found here: /etc/virtual/skip_validate_recipients


## Cache Location
We use a cache with a period of 1 month, this to avoid double checks, and thus minimize the costs for DeBounce.io API.

Cache is saved to /etc/virtual/validated_recipient/
