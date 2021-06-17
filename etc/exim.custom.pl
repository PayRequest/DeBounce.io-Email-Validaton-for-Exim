#!/usr/bin/perl
# ============================================================
# version: 0.2 $ Wed Jun 16 03:27:52 +07 2021
#          0.1 $ Mon Jun 14 20:50:54 +07 2021
# ============================================================

#
# yum -y install perl-JSON-Parse perl-LWP-Protocol-https
# dnf -y install perl-JSON-Parse perl-LWP-Protocol-https
#

# SAFE TO SEND:
# =========================================
# {
#  "debounce": {
#    "email": "test@icloud.com",
#    "code": "5",
#    "role": "false",
#    "free_email": "true",
#    "result": "Safe to Send",
#    "reason": "Deliverable",
#    "send_transactional": "1",
#    "did_you_mean": ""
#  },
#  "success": "1",
#  "balance": "57"
# }
#

# INVALID:
# =========================================
# {
#   "debounce": {
#     "email": "nothing@test.com",
#     "code": "6",
#     "role": "false",
#     "free_email": "false",
#     "result": "Invalid",
#     "reason": "Bounce",
#     "send_transactional": "0",
#     "did_you_mean": ""
#   },
#   "success": "1",
#   "balance": "56"
# }

sub px_read_from_cache
{
    my ($cache_file) = @_;

    # read cache
    if (-e $cache_file) {
        open(my $fh, '<', $cache_file);
        my $cache_ttl = 2629746; # 1 Month
        my $cached_data = <$fh>;
        if (defined $cached_data){
            chomp $cached_data;
            my ($cached_time,$check) = split(/:/, $cached_data);
            my $current_time = time;
            my $time_diff =  $current_time - $cached_time;
            if ($time_diff > $cache_ttl) {
                Exim::log_write("[DEBUG] Cache for ". $recipient ." expired: ". $time_diff);
                unlink($cache_file);
                return undef;
            } else {
                Exim::log_write("[DEBUG] Found for ". $recipient ." cached status: ". $check);
                return $check;
            }
        }
        close $fh;
    } else {
        Exim::log_write("[DEBUG] Cache-file for ". $recipient ." not found: ". $cache_file);
        return undef;
    }
}

sub px_read_from_skip_file
{
    my ($recipient) = @_;
    my $skip_file = "/etc/virtual/skip_validate_recipients";

    if (-e $skip_file) {
        #Exim::log_write("[DEBUG] Searching the recipient $recipient in a skip file: ". $skip_file);
        open(my $fh, '<', $skip_file);
        while(my $row = <$fh>)
        {
            if($row =~ /$recipient/)
            {
                Exim::log_write("[DEBUG] Found ". $recipient ." in a skip file: ". $skip_file);
                return 1;
            }
            else
            {
                #Exim::log_write("[DEBUG] NOT Found ". $recipient ." in a skip file: ". $skip_file);
            }
        }
        close $fh;
    }
    return undef;
}

sub px_is_validated_recipient
{
    my $is_validated_recipient = 0;
    my $file = "/etc/exim.custom.pl.out";
    our ($recipient) = @_; # Do not allow record splitting.

    use File::Path qw(make_path);
    use JSON qw(decode_json);
    use LWP::Simple;

    my $contents;
    my $parsed_data;

    my ($user, $domain) = split(/@/, $recipient);
    die "Could not validate email $email!" unless defined $user and defined $domain;

    my $should_be_skipped = px_read_from_skip_file($recipient);
    if ("$should_be_skipped" eq "1") {
        return "skipped";
    }

    umask(0);
    my $u_letter = substr($user, 0, 1);
    my $d_letter = substr($domain, 0, 1);
    my $cache_dir = "/etc/virtual/validated_recipient/$d_letter/$domain/$u_letter";
    make_path($cache_dir,{mode=>0770});
    my $cache_file = "$cache_dir/$user";

    my $check = px_read_from_cache($cache_file);

    if (!defined $check || $check eq '') {

        my $url = "https://api.debounce.io/v1/?api=KEYHERE&email=".$recipient;
        Exim::log_write("[DEBUG] Making an API call to check ". $recipient ." status");

        $contents = get($url);
        die "Could not get $url!" unless defined $contents;

        eval {
            $parsed_data = decode_json($contents);
        };

        die "Could not parse json!" unless defined $parsed_data;

        $check = $parsed_data->{'debounce'}->{'result'};

        # caching data
        open(my $fh, '>>', $cache_file);
        Exim::log_write("[DEBUG] Writing a cache file for ". $recipient ." with status: ". $check);
        print $fh time. ":$check\n";
        chmod 0660, $fh;
        close $fh;
    }

    if ("$check" eq "Invalid") {
        Exim::log_write("[ERROR] Recipient's email ". $recipient ." not validated: ". $check);
        $is_validated_recipient = 0;
    } else {
        Exim::log_write("[OK] Recipient's email ". $recipient ." validated: ". $check);
        $is_validated_recipient = 1;
    }

    #open(my $fh, '>>', $file);
    #print $fh time. " to=$recipient, is_validated_recipient=".$is_validated_recipient."\n";
    #close $fh;

    if ($is_validated_recipient == 1) {
        # validated recipient
        return "validated";
    } else {
        # not validated recipient
        return "caught";
    }
}
