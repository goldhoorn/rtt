#!/bin/bash

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]; then
    echo Generate LGPL Free Software Header
    echo Usage: $0 \"Copyright holder\" EMail-Address Filename
    exit 1
fi

filename=`basename $3`

export "LANG=C"

echo "/***************************************************************************" > $3.tmp.header
echo -e "  tag: $1 " `date` " $filename\n" >> $3.tmp.header
echo "                        $filename -  description" >> $3.tmp.header
echo "                           -------------------" >> $3.tmp.header
echo "    begin                : "`date "+%a %B %d %Y"` >> $3.tmp.header
echo "    copyright            : (C) "`date +%Y` $1 >> $3.tmp.header
#echo "    copyright            : (C) "`date +%Y` `cat /etc/passwd | ( IFS=: ; while read lognam pw id gp fname home sh; do echo $home \"$fname\"; done ) | /bin/grep "/home/$USER" | sed "s/\/home\/$USER\ \"//" | sed "s/,,,\"//"` >> $3.tmp.header
echo "    email                : "$2 >> $3.tmp.header
echo "" >> $3.tmp.header
echo " ***************************************************************************" >> $3.tmp.header
echo " *   This library is free software; you can redistribute it and/or         *" >> $3.tmp.header
echo " *   modify it under the terms of the GNU Lesser General Public            *" >> $3.tmp.header
echo " *   License as published by the Free Software Foundation; either          *" >> $3.tmp.header
echo " *   version 2.1 of the License, or (at your option) any later version.    *" >> $3.tmp.header
echo " *                                                                         *" >> $3.tmp.header
echo " *   This library is distributed in the hope that it will be useful,       *" >> $3.tmp.header
echo " *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *" >> $3.tmp.header
echo " *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *" >> $3.tmp.header
echo " *   Lesser General Public License for more details.                       *" >> $3.tmp.header
echo " *                                                                         *" >> $3.tmp.header
echo " *   You should have received a copy of the GNU Lesser General Public      *" >> $3.tmp.header
echo " *   License along with this library; if not, write to the Free Software   *" >> $3.tmp.header
echo " *   Foundation, Inc., 59 Temple Place,                                    *" >> $3.tmp.header
echo " *   Suite 330, Boston, MA  02111-1307  USA                                *" >> $3.tmp.header
echo " *                                                                         *" >> $3.tmp.header
echo " ***************************************************************************/" >> $3.tmp.header
echo "" >> $3.tmp.header
echo "" >> $3.tmp.header

cat $3.tmp.header $3 > $3.tmp.full
mv $3.tmp.full $3
rm $3.tmp.header
