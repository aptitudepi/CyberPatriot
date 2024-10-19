#!/bin/bash
##for ubuntu
firefox http://static.open-scap.org
echo -e "choose your flavor of linux:\n1) Ubu 22\n2)Fedora\n3)CentOS 7\n4)CentOS 8\n5)CentOS 9\n6)RHEL 6\n7)RHEL 7\n8)RHEL 9\n10)Ubu 20\n11)Debian 9\n12)Debian 10\n13) Debian 11"
read linuxver
if [$linuxver == "1"]; then
  sudo apt-get install libopenscap8 -y
  echo "running OpenSCAP for Ubuntu 22..."
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_level1_server \
/usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_level1_workstation \
/usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_level2_server \
/usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_level2_workstation \
/usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_standard \
/usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml
fi
if [$linuxver == "2"]; then
  echo "running OpenSCAP for Fedora..."
  dnf install openscap-scanner
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_ospp \
/usr/share/xml/scap/ssg/content/ssg-fedora-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_pci-dss \
/usr/share/xml/scap/ssg/content/ssg-fedora-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_standard \
/usr/share/xml/scap/ssg/content/ssg-fedora-ds.xml
fi
if [$linuxver == "3"]; then
  echo "running OpenSCAP for CentOS 7..."
  yum install openscap-scanner
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_anssi_nt28_enhanced \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_anssi_nt28_high \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_anssi_nt28_intermediary \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_anssi_nt28_minimal \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_e8 \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_C2S \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_server_l1 \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_workstation_l1 \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_workstation_l2 \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cjis \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_stig \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_stig_gui \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_hipaa \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_ncp \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_ospp \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_pci-dss \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_rhelh-stig \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_rht-ccp \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_standard \
/usr/share/xml/scap/ssg/content/ssg-centos7-ds.xml
fi
if [$linuxver == "4"]; then
  echo "pls just look it up and run it for CentOS 8"
  sleep 2
fi
if [$linuxver == "5"]; then
  echo "running OpenSCAP for CentOS 9..."
  yum install openscap-scanner
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_anssi_bp28_enhanced \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_anssi_bp28_high \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_anssi_bp28_intermediary \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_anssi_bp28_minimal \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
   oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_e8 \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_ism_o \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_server_l1 \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_workstation_l1 \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_workstation_l2 \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_hipaa \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_pci-dss \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_ospp \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_stig \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_stig_gui \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cui \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
fi
if [$linuxver == "6"]; then
  echo "pls just look it up and run it for RHEL 7"
  sleep 2
fi
if [$linuxver == "7"]; then
  echo "pls just look it up and run it for RHEL 8"
  sleep 2
fi
if [$linuxver == "8"]; then
  echo "running OpenSCAP for RHEL 9..."
  echo "jk, not needed rn"
fi
if [$linuxver == "9"]; then
fi
if [$linuxver == "10"]; then
  sudo apt-get install libopenscap8 -y
  echo "running OpenSCAP for Ubuntu 20..."
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_level1_server \
/usr/share/xml/scap/ssg/content/ssg-ubuntu2004-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_level1_workstation \
/usr/share/xml/scap/ssg/content/ssg-ubuntu2004-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_level2_server \
/usr/share/xml/scap/ssg/content/ssg-ubuntu2004-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_level2_workstation \
/usr/share/xml/scap/ssg/content/ssg-ubuntu2004-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_stig \
/usr/share/xml/scap/ssg/content/ssg-ubuntu2004-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_standard \
/usr/share/xml/scap/ssg/content/ssg-ubuntu2004-ds.xml
fi
if [$linuxver == "11"]; then
fi
if [$linuxver == "12"]; then
fi
if [$linuxver == "13"]; then
  echo "running OpenSCAP for Debian 11..."
  sudo apt-get install libopenscap8 -y
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_anssi_np_nt28_average \
/usr/share/xml/scap/ssg/content/ssg-debian11-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_anssi_np_nt28_high \
/usr/share/xml/scap/ssg/content/ssg-debian11-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_anssi_np_nt28_minimal \
/usr/share/xml/scap/ssg/content/ssg-debian11-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_anssi_np_nt28_restrictive \
/usr/share/xml/scap/ssg/content/ssg-debian11-ds.xml
  oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_standard \
/usr/share/xml/scap/ssg/content/ssg-debian11-ds.xml
fi
#oscap -V
#wget https://security-metadata.canonical.com/oval/com.ubuntu.$(lsb_release -cs).usn.oval.xml.bz2
#apt install bunzip2 -y
#bunzip2 com.ubuntu.$(lsb_release -cs).usn.oval.xml.bz2
#unzip com.ubuntu.$(lsb_release -cs).usn.oval.xml.bz2
#oscap oval eval --results oval-results.xml com.ubuntu.$(lsb_release -cs).usn.oval.xml
#oscap oval collect --syschar syschar.xml  com.ubuntu.$(lsb_release -cs).usn.oval.xml
#wget "https://github.com/OpenSCAP/openscap/releases/download/1.3.7/openscap-1.3.7.tar.gz"
#apt install gzip -y
#gunzip openscap-1.3.7.tar.gz
#tar -xvf openscap-1.3.7.tar
#cd openscap-1.3.7
#ls > ~/scapstuff.txt
