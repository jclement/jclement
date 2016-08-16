---
title: Netflix and HE.NET IPv6 Tunnels
date: 2016-08-16
template: article.jade
comments: true
toc: false
---

About a year ago I brought up a [Hurricane Electric](https://tunnelbroker.net "TunnelBroker.net") IPv6 tunnel so that I could start experimenting with IPv6 on our home network (at the time, and even now, our ISP doesn't natively support IPv6 - After all, IPv6 is only about 20 years old...).

I live in Canada so I chose HE's Winnipeg data centre so that both my IPv4 and IPv6 traffic would geolocate to Canada. Checking [IPv6-test.com](http://ipv6-test.com/) showed a working IPv6 configuration (19/20) and geolocation for both in Canada.

This all worked smashingly.

Within a few weeks, however, we noticed that some of our devices (namely the newer Apple ones) would show Netflix U.S. while others that didn't support IPv6 (we're looking at you Nintendo Wii) would show Netflix Canada. This actually turned out to be extraordinarily annoying since moving between devices or networks would change show availability.

However, in May/June Netflix started actively blocking our home devices with a message indicating we should turn off our VPN.

Phone calls to Netflix support proved to be fruitless. Their support people didn't understand IPv6, why this isn't a VPN, and were unwilling to escalate to someone who could.  You'd think that between my Canadian IPv4 address, my Canadian IPv6 address, and my Canadian credit card they could deduce that maybe I really am in Canada.

My thought was then to try and block Netflix IPv6 traffic entirely by either:

1. Blocking IPv6 DNS requests for \*.netflix.com
2. Blocking outgoing traffic to Netflix IPv6 addresses

The former is difficult because my MikroTik router doesn't allow me to override AAAA requests and I had no desire to configure a separate DNS server for this purpose.

The later is difficult because Netflix has machines all over the place and huge ranges of addresses that, I believe, change depending on which region you are in.

After some Googling I found some posts ([here](https://community.ubnt.com/t5/EdgeMAX/Blocking-IPv6-traffic-to-Netflix-over-HE-net-tunnel/td-p/1587619) and [here](https://forums.he.net/index.php?topic=3564.0)) indicating you could block the following address ranges with some success:

1. [2620:108:700f::](https://whois.arin.net/rest/net/NET6-2620-108-7000-1/pft?s=2620%3A108%3A700f%3A%3A)/48
2. [2406:da00:ff00::](https://whois.arin.net/rest/net/NET6-2400-1/pft?s=2406%3Ada00%3Aff00%3A%3A)/48

On my MikroTik box I added those addresses to a "Netflix" address group on my firewall and then blocked all outbound traffic to those addresses.

```
/ipv6 firewall address-list
add address=2620:108:700f::/48 list=netflix
add address=2406:da00:ff00::/48 list=netflix

/ipv6 firewall filter
add action=reject chain=forward comment="Disable IPv6 for Netflix" \
dst-address-list=netflix log-prefix="" reject-with=icmp-address-unreachable
```

This has _resolved_ the issue for us although it's a hack and there are some problems:

1. Blocking entire /48's is a bit extreme. The first of these address ranges is associated with Amazon EC2 so I _assume_ I'm blocking vast swaths of other IPv6 content.
2. It's slow. Netflix Apps need to wait for the IPv6 requests to timeout before they fallback to IPv4. It often takes upwards of 60 seconds to start playing something on our AppleTV.
3. It's lame.  Hey **Netflix**, fix your system!

