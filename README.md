# DeBounce.io  Email Validaton for Exim

![debounce](https://ik.imagekit.io/debounce/wp-content/uploads/2020/11/debounce-validation-card-p.png)


Check outgoing email sent with Exim, the checks are performed with the DeBounce API.

Please consider limit rate:
The maximum number of concurrent calls (parallel connections) is 10. If you validate emails with a higher speed, you will get an error



## Installation

1. Add the follow line to exim.routers.pre.conf:
```
no_more
```

2. Add the following files:

```
/etc/exim.acl_check_recipient.pre.conf
/etc/exim.acl_script.pre.conf
/etc/exim.custom.pl
```

3. Change API key in: 

```
/etc/exim.custom.pl:
```

4. Create Skip list


```
touch /etc/virtual/skip_validate_recipients
```



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
