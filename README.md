# DeBounce.io  Email Validaton for Exim
Check outgoing email sent with Exim, the checks are performed with the DeBounce API.



## Installation



#$ Add email adresses to the allow list
A skip file can be found here: /etc/virtual/skip_validate_recipients


## Cache Location
We use a cache with a period of 1 month, this to avoid double checks, and thus minimize the costs for DeBounce.io API.

Cache is saved to /etc/virtual/validated_recipient/
