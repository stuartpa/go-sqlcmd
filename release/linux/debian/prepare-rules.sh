#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
#------------------------------------------------------------------------------

# Description:
#
# Create the debian/directory for building the go-mssqltools Debian package and
# the package rules.
#
# Usage:
#
# build.sh DEBIAN-DIR SRC_DIR
#

set -evx

if [[ -z "$1" ]]
  then
    echo "No argument supplied for debian directory."
    exit 1
fi

if [[ -z "$2" ]]
  then
    echo "No argument supplied for source directory."
    exit 1
fi

TAB=$'\t'

debian_dir=$1
source_dir=$2

mkdir -p $debian_dir/source || exit 1

echo '1.0' > $debian_dir/source/format
echo '9' > $debian_dir/compat

cat > $debian_dir/changelog <<- EOM
go-mssqltools (${CLI_VERSION}-${CLI_VERSION_REVISION:=1}) unstable; urgency=low

  * Debian package release.

 -- go-mssqltools cli Team <dpgswdist@microsoft.com@microsoft.com>  $(date -R)

EOM

cat > $debian_dir/control <<- EOM
Source: go-mssqltools
Section: golang
Priority: extra
Maintainer: go-mssql tools Team <dpgswdist@microsoft.com>
Build-Depends: debhelper (>= 9)
Standards-Version: 3.9.5
Homepage: http://www.microsoft.com/sql

Package: go-mssqltools
Architecture: all
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: GO MSSQL TOOLS CLI
 GO MSSQL TOOLS CLI, a multi-platform command line experience for SQL Server and Azure SQL.

EOM

cat > $debian_dir/copyright <<- EOM
Format: http://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: go-mssqltools
Upstream-Contact: go-mssql tools Team <stuartpa@microsoft.com>
Source: PRIVATE

Files: *
Copyright: Copyright (c) Microsoft Corporation
License: https://aka.ms/eula-go-mssqltools-en

MICROSOFT SOFTWARE LICENSE TERMS
MICROSOFT GO MSSQL TOOLS CLI
________________________________________
These license terms are an agreement between you and Microsoft Corporation (or
one of its affiliates). They apply to the software named above and any
Microsoft services or software updates (except to the extent such services or
updates are accompanied by new or additional terms, in which case those
different terms apply prospectively and do not alter your or Microsoft’s rights
relating to pre-updated software or services). IF YOU COMPLY WITH THESE LICENSE
TERMS, YOU HAVE THE RIGHTS BELOW. BY USING THE SOFTWARE, YOU ACCEPT THESE TERMS.

1.	INSTALLATION AND USE RIGHTS.
    a)	General. You may install and use any number of copies of the software.
    b)	Third Party Software. The software may include third party applications
        that Microsoft, not the third party, licenses to you under this
        agreement. Any included notices for third party applications are for
        your information only.

2.	DATA COLLECTION. The software may collect information about you and your
    use of the software and send that to Microsoft. Microsoft may use this
    information to provide services and improve Microsoft’s products and
    services. Your opt-out rights, if any, are described in the product
    documentation. Some features in the software may enable collection of data
    from users of your applications that access or use the software. If you use
    these features to enable data collection in your applications, you must
    comply with applicable law, including getting any required user consent,
    and maintain a prominent privacy policy that accurately informs users about
    how you use, collect, and share their data. You can learn more about
    Microsoft’s data collection and use in the product documentation and the
    Microsoft Privacy Statement at
    [https://go.microsoft.com/fwlink/?LinkId=521839]. You agree to comply with
    all applicable provisions of the Microsoft Privacy Statement.

3.	SCOPE OF LICENSE. The software is licensed, not sold. Microsoft reserves
    all other rights. Unless applicable law gives you more rights despite this
    limitation, you will not (and have no right to):
    a)	work around any technical limitations in the software that only allow
        you to use it in certain ways;
    b)	reverse engineer, decompile or disassemble the software;
    c)	remove, minimize, block, or modify any notices of Microsoft or its
        suppliers in the software;
    d)	use the software in any way that is against the law or to create or
        propagate malware; or
    e)	share, publish, distribute, or lend the software, provide the software
        as a stand-alone hosted solution for others to use, or transfer the
        software or this agreement to any third party.

4.	EXPORT RESTRICTIONS. You must comply with all domestic and international
    export laws and regulations that apply to the software, which include
    restrictions on destinations, end users, and end use. For further
    information on export restrictions, visit http://aka.ms/exporting.

5.	SUPPORT SERVICES. Microsoft is not obligated under this agreement to
    provide any support services for the software. Any support provided is
    “as is”, “with all faults”, and without warranty of any kind.

6.	UPDATES. The software may periodically check for updates, and download and
    install them for you. You may obtain updates only from Microsoft or
    authorized sources. Microsoft may need to update your system to provide you
    with updates. You agree to receive these automatic updates without any
    additional notice. Updates may not include or support all existing software
    features, services, or peripheral devices.

7.	ENTIRE AGREEMENT. This agreement, and any other terms Microsoft may provide
    for supplements, updates, or third-party applications, is the entire
    agreement for the software.

8.	APPLICABLE LAW AND PLACE TO RESOLVE DISPUTES. If you acquired the software
    in the United States or Canada, the laws of the state or province where you
    live (or, if a business, where your principal place of business is located)
    govern the interpretation of this agreement, claims for its breach, and all
    other claims (including consumer protection, unfair competition, and tort
    claims), regardless of conflict of laws principles. If you acquired the
    software in any other country, its laws apply. If U.S. federal jurisdiction
    exists, you and Microsoft consent to exclusive jurisdiction and venue in
    the federal court in King County, Washington for all disputes heard in
    court. If not, you and Microsoft consent to exclusive jurisdiction and venue
    in the Superior Court of King County, Washington for all disputes heard in
    court.

9.	CONSUMER RIGHTS; REGIONAL VARIATIONS. This agreement describes certain
    legal rights. You may have other rights, including consumer rights, under
    the laws of your state, province, or country. Separate and apart from your
    relationship with Microsoft, you may also have rights with respect to the
    party from which you acquired the software. This agreement does not change
    those other rights if the laws of your state, province, or country do not
    permit it to do so. For example, if you acquired the software in one of the
    below regions, or mandatory country law applies, then the following
    provisions apply to you:

    a)	Australia. You have statutory guarantees under the Australian Consumer
        Law and nothing in this agreement is intended to affect those rights.
    b)	Canada. If you acquired this software in Canada, you may stop receiving
        updates by turning off the automatic update feature, disconnecting your
        device from the Internet (if and when you re-connect to the Internet,
        however, the software will resume checking for and installing updates),
        or uninstalling the software. The product documentation, if any, may
        also specify how to turn off updates for your specific device or
        software.
    c)	Germany and Austria.
        i.	Warranty. The properly licensed software will perform
            substantially as described in any Microsoft materials that accompany
            the software. However, Microsoft gives no contractual guarantee in
            relation to the licensed software.
        ii.	Limitation of Liability. In case of intentional conduct, gross
            negligence, claims based on the Product Liability Act, as well as,
            in case of death or personal or physical injury, Microsoft is
            liable according to the statutory law.

            Subject to the foregoing clause ii., Microsoft will only be liable
            for slight negligence if Microsoft is in breach of such material
            contractual obligations, the fulfillment of which facilitate the
            due performance of this agreement, the breach of which would
            endanger the purpose of this agreement and the compliance with
            which a party may constantly trust in (so-called "cardinal
            obligations"). In other cases of slight negligence, Microsoft will
            not be liable for slight negligence.

10.	DISCLAIMER OF WARRANTY. THE SOFTWARE IS LICENSED “AS IS.” YOU BEAR THE RISK
    OF USING IT. MICROSOFT GIVES NO EXPRESS WARRANTIES, GUARANTEES, OR
    CONDITIONS. TO THE EXTENT PERMITTED UNDER APPLICABLE LAWS, MICROSOFT
    EXCLUDES ALL IMPLIED WARRANTIES, INCLUDING MERCHANTABILITY, FITNESS FOR A
    PARTICULAR PURPOSE, AND NON-INFRINGEMENT.

11.	LIMITATION ON AND EXCLUSION OF DAMAGES. IF YOU HAVE ANY BASIS FOR
    RECOVERING DAMAGES DESPITE THE PRECEDING DISCLAIMER OF WARRANTY, YOU CAN
    RECOVER FROM MICROSOFT AND ITS SUPPLIERS ONLY DIRECT DAMAGES UP TO U.S.
    $5.00. YOU CANNOT RECOVER ANY OTHER DAMAGES, INCLUDING CONSEQUENTIAL, LOST
    PROFITS, SPECIAL, INDIRECT OR INCIDENTAL DAMAGES.

    This limitation applies to (a) anything related to the software, services,
    content (including code) on third party Internet sites, or third party
    applications; and (b) claims for breach of contract, warranty, guarantee,
    or condition; strict liability, negligence, or other tort; or any other
    claim; in each case to the extent permitted by applicable law.

    It also applies even if Microsoft knew or should have known about the
    possibility of the damages. The above limitation or exclusion may not
    apply to you because your state, province, or country may not allow the
    exclusion or limitation of incidental, consequential, or other damages.

Please note: As this software is distributed in Canada, some of the clauses
in this agreement are provided below in French.

Remarque: Ce logiciel étant distribué au Canada, certaines des clauses dans
ce contrat sont fournies ci-dessous en français.

EXONÉRATION DE GARANTIE. Le logiciel visé par une licence est offert
« tel quel ». Toute utilisation de ce logiciel est à votre seule risque et
péril. Microsoft n’accorde aucune autre garantie expresse. Vous pouvez
bénéficier de droits additionnels en vertu du droit local sur la
protection des consommateurs, que ce contrat ne peut modifier. La ou elles
sont permises par le droit locale, les garanties implicites de qualité
marchande, d’adéquation à un usage particulier et d’absence de contrefaçon sont
exclues.

LIMITATION DES DOMMAGES-INTÉRÊTS ET EXCLUSION DE RESPONSABILITÉ POUR LES
DOMMAGES. Vous pouvez obtenir de Microsoft et de ses fournisseurs une
indemnisation en cas de dommages directs uniquement à hauteur de 5,00 $ US.
Vous ne pouvez prétendre à aucune indemnisation pour les autres dommages, y
compris les dommages spéciaux, indirects ou accessoires et pertes de bénéfices.
Cette limitation concerne:

•	tout ce qui est relié au logiciel, aux services ou au contenu (y compris
    le code) figurant sur des sites Internet tiers ou dans des programmes
    tiers; et
•	les réclamations au titre de violation de contrat ou de garantie, ou au
    titre de responsabilité stricte, de négligence ou d’une autre faute dans la
    limite autorisée par la loi en vigueur.

Elle s’applique également, même si Microsoft connaissait ou devrait connaître
l’éventualité d’un tel dommage. Si votre pays n’autorise pas l’exclusion ou la
limitation de responsabilité pour les dommages indirects, accessoires ou de
quelque nature que ce soit, il se peut que la limitation ou l’exclusion
ci-dessus ne s’appliquera pas à votre égard.

EFFET JURIDIQUE. Le présent contrat décrit certains droits juridiques. Vous
pourriez avoir d’autres droits prévus par les lois de votre pays. Le présent
contrat ne modifie pas les droits que vous confèrent les lois de votre pays
si celles-ci ne le permettent pas.

EOM

cat > $debian_dir/rules << EOM
#!/usr/bin/make -f

# Uncomment this to turn on verbose mode.
export DH_VERBOSE=1
export DH_OPTIONS=-v

%:
${TAB}dh \$@ --sourcedirectory $source_dir

override_dh_install:
${TAB}mkdir -p debian/go-mssqltools/usr/bin/
${TAB}cp -r /opt/stage/sqlcmd debian/go-mssqltools/usr/bin/sqlcmd
${TAB}chmod 0755 debian/go-mssqltools/usr/bin/sqlcmd

override_dh_strip:
${TAB}dh_strip --exclude=_cffi_backend

EOM

cat $debian_dir/rules

# Debian rules should be executable
chmod 0755 $debian_dir/rules
