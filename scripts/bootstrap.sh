#!/bin/bash

## Copyright (c) 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

pip3 install oci pyclamd
#
echo "Install and Update ClamAV Started"
yum -y install clamav clamd 
ln -s /etc/clamd.d/scan.conf /etc/clamd.conf
echo "LocalSocket /run/clamd.scan/clamd.sock" >>/etc/clamd.conf
echo "StreamMaxLength 1000M" >>/etc/clamd.conf
/usr/sbin/setsebool -P antivirus_can_scan_system 1 
/usr/bin/freshclam 
/usr/bin/systemctl start clamd@scan 
/usr/bin/systemctl enable clamd@scan 
echo "ClamAV Installation Ended"
