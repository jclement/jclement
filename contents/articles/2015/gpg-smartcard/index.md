---
title: Using GPG with Smart Cards
date: 2015-04-14
template: article.jade
---

I use SSH daily (with SSH keys) and would like to use GPG routinely (if only people I conversed with would use it).  My concern has always been key management.  I don't like that I'm leaving secret keys on my work computer, work laptop, various home computers, etc.  

Enter [smart cards](http://en.wikipedia.org/wiki/Smart_card)...  

Smart cards let you store the RSA private key information on a tamper resistant piece of hardware instead of scattered across various computers where it can be accessed by other users of the machine, malicious software, etc.  Software can ask the smart card to perform cryptographic operations on its behalf without disclosing the key to the computer (in fact, there is no reasonable way to extract the private key from a smart card).  To prevent unauthorized use the smart code requires the user provide a 6 digit PIN.  If the PIN is entered incorrectly three times the card is blocked and must be reset using the administrative PIN.  If the administrative PIN is entered incorrectly the card is rendered inoperable.  All of this sounds fantastic.  It significantly increases the security of my keys and doesn't require me to use long passwords to encrypt my GPG/SSH keys on my individual machines. 

Unfortunately, finding information about setting up and using smart cards for use with GPG and SSH under Linux, Windows and OSX seems difficult.

This article covers how I setup and use smart cards.

# Required Hardware

Obviously, one needs a smart card.  

For day-to-day use I

# Setup
## Setting up the air-gapped machine

I chose to generate my GPG keys on an air-gapped (non-network connected) Debian LiveCD to prevent any accidental leakage of my keys.  Once the keys are generated I copy them onto backup media and then load them onto my smart card for daily use.  

Download Debian Live install image from [here](https://www.debian.org/CD/live/) (I used 7.8.0-amd64-standard).

Boot the Live CD and attach it to the network.

Install additional dependencies on the machine:

```sh
$ apt-get install gnupg2
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
Unplug your network cable now
</div>

## Enabling OpenPGP on Yubikey

If you are using a Yubikey Neo for your smart card you'll need to enable CCID mode 

## Generating keys
## Loading sub-keys onto the smart card


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

## OSX
### Required software
