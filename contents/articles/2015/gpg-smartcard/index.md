---
title: Using GPG with Smart Cards
date: 2015-04-14
template: article.jade
---

I use SSH daily (with SSH keys) and would like to use GPG routinely (if only people I conversed with would use it).  My concern has always been key management.  I don't like that I'm leaving secret keys on my work computer, work laptop, various home computers, etc.  This also means that I need a strong password on each of these keys which makes actually using them annoying.

Enter [smart cards](http://en.wikipedia.org/wiki/Smart_card)...  

Smart cards let you store the RSA private key information on a tamper resistant piece of hardware instead of scattered across various computers where it can be accessed by other users of the machine, malicious software, etc.  Software can ask the smart card to perform cryptographic operations on its behalf without disclosing the key to the computer (in fact, there is no reasonable way to extract the private key from a smart card).  To prevent unauthorized use the smart code requires the user provide a 6 digit PIN.  If the PIN is entered incorrectly three times the card is blocked and must be reset using the administrative PIN.  If the administrative PIN is entered incorrectly the card is rendered inoperable.  The smart cards significantly increases the security of my keys and doesn't require me to use long passwords to encrypt my GPG/SSH keys on my individual machines. 

Unfortunately, finding information about setting up and using smart cards for use with GPG and SSH under Linux, Windows and OSX seems difficult.

This article covers how I setup and use smart cards.

# Required Hardware

Obviously, one needs a smart card.  

For day-to-day use I chose the [Yubikey Neo](https://www.yubico.com/products/yubikey-hardware/yubikey-neo/).  I've LOVED the Yubikey product line for years primarily because they are small, versatile, and indestructible.  I bought mine from [Amazon for $60](http://www.amazon.ca/dp/B00LX8KZZ8). The downside is that there is no on-device PIN entry mechanism so you rely on a software PIN which is susceptible to key logging.  Another potential downside is that the NEO only supports 2048-bit RSA keys although those are [still acceptably strong](https://www.digicert.com/TimeTravel/math.htm).

Another option is to buy a dedicated OpenPGP smart card from [Kernel Concepts](http://shop.kernelconcepts.de/).  The advantage here is that you have the option of using a smart card reader with a hardware keypad which mitigates much of the key logging issue the NEO is susceptible to.  The OpenPGP Smart Card V2.1 also supports 4096-bit RSA keys.  

Other than a few Yubikey specific setup steps the process for both devices is the same.

## Enabling OpenPGP on Yubikey

If you are using a Yubikey Neo for your smart card you'll need to enable CCID mode and, while you are at it, may as well enable Fido U2F mode too.  This isn't enabled by default.  

For simultaneous OTP, CCID and U2F you need firmware 3.3.0 or higher.

Use the [Yubikey Neo Manager](https://developers.yubico.com/yubikey-neo-manager/Releases/) (I used 1.2.1) to verify your Yubikey firmware version and to enable OTP+CCID+U2F.

I did this on Windows because it was convenient but there are packages for OSX and Linux too.

![Yubikey Neo Manager](yubikey-mode.png)

# Setup
## Setting up the air-gapped machine

I chose to generate my GPG keys on an air-gapped (non-network connected) Debian LiveCD to prevent any accidental leakage of my keys.  Once the keys are generated I copy them onto backup media (multiple backup media) and then load them onto my smart card for daily use.  

Download Debian Live install image from [here](https://www.debian.org/CD/live/) (I used 7.8.0-amd64-standard) and install on USB thumb-drive using a method appropriate for your OS of choice.

Boot the Live CD and attach it to the network.

Install additional dependencies on the machine:

```sh
$ apt-get install gnupg2 gnupg-agent libpth20 pinentry-curses libccid pcscd scdaemon libksba8
```

Configure GnuPG with safer defaults / strong default ciphers (from riseup.net):

```sh
$ mkdir ~/.gnupg
$ cat > ~/.gnupg/gpg.conf << !
no-emit-version
no-comments
keyid-format 0xlong
with-fingerprint
use-agent
personal-cipher-preferences AES256 AES192 AES CAST5
personal-digest-preferences SHA512 SHA384 SHA256 SHA224
cert-digest-algo SHA512
default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
!
```

<div class="alert alert-danger">
<i class="glyphicon glyphicon-exclamation-sign"></i> Unplug your network cable now and verify that machine no longer has network connectivity.
</div>

## Generating keys

<div class="alert alert-danger">
<i class="glyphicon glyphicon-exclamation-sign"></i> Be absolutely sure you have a backup of your GPG keys before you continue.  This backup is necessary for several reasons:
<ol>
 <li>If your smart card is lost or damaged you can create a new one and (optionally) revoke the sub-keys that were in use on the previous card.
 <li>The sub-keys on the smart card are limited and can not sign other keys, change your expiry date, or add UIDs to your existing key
</ol>
</div>

## Generating a revocation key

## Backup your GPG key(s)

## Loading sub-keys onto the smart card

## Distributing your public key

# Usage

## Linux
### Required software
### Outstanding issues

## Windows
### Required software

Download and install [GPG4Win 2.2.4 or higher](http://www.gpg4win.org/download.html).  The default settings are fine.

### Configuration

1. a
2. a
3. d
4. Enable "Enable putty support" in Kleopatra to allow the Smartcard to be used for SSH authentication.
   ![Windows Configuration](windows/windows_configuration.png)

### Outstanding issues

#### SSH Authentication Fails

Sometimes Putty doesn't authenticate using the smart card.  I'm not sure why this is happening but I can generally fix it by closing Kleopatra, killing the gpg-agent process, and restarting Kleopatra.

## OSX
### Required software

# References

- [Offline GnuPG Master Key and Subkeys on YubiKey NEO Smartcard](http://blog.josefsson.org/2014/06/23/offline-gnupg-master-key-and-subkeys-on-yubikey-neo-smartcard/) - This post was my primary source for getting up and running with the Yubikey NEO and for structuring my sub-keys.  