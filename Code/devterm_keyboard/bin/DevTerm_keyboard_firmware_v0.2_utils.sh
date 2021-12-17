#!/bin/sh
# This script was generated using Makeself 2.4.3
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="1234143650"
MD5="8ff4b7da8acce238ad06e39d1cf34139"
SHA="0000000000000000000000000000000000000000000000000000000000000000"
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"
export USER_PWD
ARCHIVE_DIR=`dirname "$0"`
export ARCHIVE_DIR

label="keyboard_firmware"
script="./flash.sh"
scriptargs=""
cleanup_script=""
licensetxt=""
helpheader=''
targetdir="DevTerm_keyboard_firmware_v0.2_utils"
filesizes="103941"
totalsize="103941"
keep="n"
nooverwrite="n"
quiet="n"
accept="n"
nodiskspace="n"
export_conf="n"
decrypt_cmd=""
skip="678"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

if test -d /usr/xpg4/bin; then
    PATH=/usr/xpg4/bin:$PATH
    export PATH
fi

if test -d /usr/sfw/bin; then
    PATH=$PATH:/usr/sfw/bin
    export PATH
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  if test x"$licensetxt" != x; then
    if test x"$accept" = xy; then
      echo "$licensetxt"
    else
      echo "$licensetxt" | more
    fi
    if test x"$accept" != xy; then
      while true
      do
        MS_Printf "Please type y to accept, n otherwise: "
        read yn
        if test x"$yn" = xn; then
          keep=n
          eval $finish; exit 1
          break;
        elif test x"$yn" = xy; then
          break;
        fi
      done
    fi
  fi
}

MS_diskspace()
{
	(
	df -kP "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    # Test for ibs, obs and conv feature
    if dd if=/dev/zero of=/dev/null count=1 ibs=512 obs=512 conv=sync 2> /dev/null; then
        dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
        { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
          test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
    else
        dd if="$1" bs=$2 skip=1 2> /dev/null
    fi
}

MS_dd_Progress()
{
    if test x"$noprogress" = xy; then
        MS_dd "$@"
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd ibs=$offset skip=1 count=0 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
${helpheader}Makeself version 2.4.3
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet               Do not print anything except error messages
  --accept              Accept the license
  --noexec              Do not run embedded script (implies --noexec-cleanup)
  --noexec-cleanup      Do not run embedded cleanup script
  --keep                Do not erase target directory after running
                        the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the target folder to the current user
  --chown               Give the target folder to the current user recursively
  --nodiskspace         Do not check for available disk space
  --target dir          Extract directly to a target directory (absolute or relative)
                        This directory may undergo recursive chown (see --nochown).
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --ssl-pass-src src    Use the given src as the source of password to decrypt the data
                        using OpenSSL. See "PASS PHRASE ARGUMENTS" in man openssl.
                        Default is to prompt the user to enter decryption password
                        on the current terminal.
  --cleanup-args args   Arguments to the cleanup script. Wrap in quotes to provide
                        multiple arguments.
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || command -v md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || command -v md5 || type md5`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || command -v digest || type digest`
    PATH="$OLD_PATH"

    SHA_PATH=`exec <&- 2>&-; which shasum || command -v shasum || type shasum`
    test -x "$SHA_PATH" || SHA_PATH=`exec <&- 2>&-; which sha256sum || command -v sha256sum || type sha256sum`

    if test x"$quiet" = xn; then
		MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n "$skip" "$1" | wc -c | tr -d " "`
    fsize=`cat "$1" | wc -c | tr -d " "`
    if test $totalsize -ne `expr $fsize - $offset`; then
        echo " Unexpected archive size." >&2
        exit 2
    fi
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$SHA_PATH"; then
			if test x"`basename $SHA_PATH`" = xshasum; then
				SHA_ARG="-a 256"
			fi
			sha=`echo $SHA | cut -d" " -f$i`
			if test x"$sha" = x0000000000000000000000000000000000000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded SHA256 checksum." >&2
			else
				shasum=`MS_dd_Progress "$1" $offset $s | eval "$SHA_PATH $SHA_ARG" | cut -b-64`;
				if test x"$shasum" != x"$sha"; then
					echo "Error in SHA256 checksums: $shasum is different from $sha" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " SHA256 checksums are OK." >&2
				fi
				crc="0000000000";
			fi
		fi
		if test -x "$MD5_PATH"; then
			if test x"`basename $MD5_PATH`" = xdigest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test x"$md5" = x00000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd_Progress "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test x"$md5sum" != x"$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test x"$crc" = x0000000000; then
			test x"$verb" = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd_Progress "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test x"$sum1" != x"$crc"; then
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2
			elif test x"$quiet" = xn; then
				MS_Printf " CRC checksums are OK." >&2
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test x"$quiet" = xn; then
		echo " All good."
    fi
}

MS_Decompress()
{
    if test x"$decrypt_cmd" != x""; then
        { eval "$decrypt_cmd" || echo " ... Decryption failed." >&2; } | eval "gzip -cd"
    else
        eval "gzip -cd"
    fi
    
    if test $? -ne 0; then
        echo " ... Decompression failed." >&2
    fi
}

UnTAR()
{
    if test x"$quiet" = xn; then
		tar $1vf -  2>&1 || { echo " ... Extraction failed." > /dev/tty; kill -15 $$; }
    else
		tar $1f -  2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    fi
}

MS_exec_cleanup() {
    if test x"$cleanup" = xy && test x"$cleanup_script" != x""; then
        cleanup=n
        cd "$tmpdir"
        eval "\"$cleanup_script\" $scriptargs $cleanupargs"
    fi
}

MS_cleanup()
{
    echo 'Signal caught, cleaning up' >&2
    MS_exec_cleanup
    cd "$TMPROOT"
    rm -rf "$tmpdir"
    eval $finish; exit 15
}

finish=true
xterm_loop=
noprogress=n
nox11=n
copy=none
ownership=n
verbose=n
cleanup=y
cleanupargs=

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
	--accept)
	accept=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 312 KB
	echo Compression: gzip
	if test x"n" != x""; then
	    echo Encryption: n
	fi
	echo Date of packaging: Fri Dec 17 12:51:39 CST 2021
	echo Built with Makeself version 2.4.3
	echo Build command was: "/usr/local/bin/makeself.sh \\
    \"DevTerm_keyboard_firmware_v0.2_utils\" \\
    \"DevTerm_keyboard_firmware_v0.2_utils.sh\" \\
    \"keyboard_firmware\" \\
    \"./flash.sh\""
	if test x"$script" != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
		echo "Root permissions required for extraction"
	fi
	if test x"n" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
    echo CLEANUPSCRIPT=\"$cleanup_script\"
	echo archdirname=\"DevTerm_keyboard_firmware_v0.2_utils\"
	echo KEEP=n
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
    echo totalsize=\"$totalsize\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5sum\"
	echo SHAsum=\"$SHAsum\"
	echo SKIP=\"$skip\"
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n "$skip" "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n "$skip" "$0" | wc -c | tr -d " "`
	arg1="$2"
    if ! shift 2; then MS_Help; exit 1; fi
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | tar "$arg1" - "$@"
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
    cleanup_script=""
	shift
	;;
    --noexec-cleanup)
    cleanup_script=""
    shift
    ;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir="${2:-.}"
    if ! shift 2; then MS_Help; exit 1; fi
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --chown)
        ownership=y
        shift
        ;;
    --nodiskspace)
	nodiskspace=y
	shift
	;;
    --xwin)
	if test "n" = n; then
		finish="echo Press Return to close this window...; read junk"
	fi
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
	--ssl-pass-src)
	if test x"n" != x"openssl"; then
	    echo "Invalid option --ssl-pass-src: $0 was not encrypted with OpenSSL!" >&2
	    exit 1
	fi
	decrypt_cmd="$decrypt_cmd -pass $2"
	if ! shift 2; then MS_Help; exit 1; fi
	;;
    --cleanup-args)
    cleanupargs="$2"
    if ! shift 2; then MS_help; exit 1; fi
    ;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test x"$quiet" = xy -a x"$verbose" = xy; then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

if test x"n" = xy -a `id -u` -ne 0; then
	echo "Administrative privileges required for this archive (use su or sudo)" >&2
	exit 1	
fi

if test x"$copy" \!= xphase2; then
    MS_PrintLicense
fi

case "$copy" in
copy)
    tmpdir="$TMPROOT"/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test x"$nox11" = xn; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm gnome-terminal rxvt dtterm eterm Eterm xfce4-terminal lxterminal kvt konsole aterm terminology"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -e "$0 --xwin $initargs"
                else
                    exec $XTERM -e "./$0 --xwin $initargs"
                fi
            fi
        fi
    fi
fi

if test x"$targetdir" = x.; then
    tmpdir="."
else
    if test x"$keep" = xy; then
	if test x"$nooverwrite" = xy && test -d "$targetdir"; then
            echo "Target directory $targetdir already exists, aborting." >&2
            exit 1
	fi
	if test x"$quiet" = xn; then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp "$tmpdir" || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x"$SETUP_NOCHECK" != x1; then
    MS_Check "$0"
fi
offset=`head -n "$skip" "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 312 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test x"$quiet" = xn; then
    # Decrypting with openssl will ask for password,
    # the prompt needs to start on new line
	if test x"n" = x"openssl"; then
	    echo "Decrypting and uncompressing $label..."
	else
        MS_Printf "Uncompressing $label"
	fi
fi
res=3
if test x"$keep" = xn; then
    trap MS_cleanup 1 2 3 15
fi

if test x"$nodiskspace" = xn; then
    leftspace=`MS_diskspace "$tmpdir"`
    if test -n "$leftspace"; then
        if test "$leftspace" -lt 312; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (312 KB)" >&2
            echo "Use --nodiskspace option to skip this check and proceed anyway" >&2
            if test x"$keep" = xn; then
                echo "Consider setting TMPDIR to a directory with more free space."
            fi
            eval $finish; exit 1
        fi
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | MS_Decompress | ( cd "$tmpdir"; umask $ORIG_UMASK ; UnTAR xp ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test x"$quiet" = xn; then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$export_conf" = x"y"; then
        MS_BUNDLE="$0"
        MS_LABEL="$label"
        MS_SCRIPT="$script"
        MS_SCRIPTARGS="$scriptargs"
        MS_ARCHDIRNAME="$archdirname"
        MS_KEEP="$KEEP"
        MS_NOOVERWRITE="$NOOVERWRITE"
        MS_COMPRESS="$COMPRESS"
        MS_CLEANUP="$cleanup"
        export MS_BUNDLE MS_LABEL MS_SCRIPT MS_SCRIPTARGS
        export MS_ARCHDIRNAME MS_KEEP MS_NOOVERWRITE MS_COMPRESS
    fi

    if test x"$verbose" = x"y"; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval "\"$script\" $scriptargs \"\$@\""; res=$?;
		fi
    else
		eval "\"$script\" $scriptargs \"\$@\""; res=$?
    fi
    if test "$res" -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi

MS_exec_cleanup

if test x"$keep" = xn; then
    cd "$TMPROOT"
    rm -rf "$tmpdir"
fi
eval $finish; exit $res
� [�a�]�wӸ�����К�M��I�g�Ҳ��.�^�rxܽ�P[I�8v��,t��;3��Wy��[������h4���h�V���W�wE$+�zsk�Y�;���g����?����7����n6�/\�kv�~�n֚�fͮ�7�F�S���޸�+�1�����j��8��b�n�k��ݪu*�V�޴���O�~��v�v�ݮ��4�Z��>u>��F~� WE��%j�G���j���\��v�}�ծR��I��r�z���� w]�y���\c��������?�{p����{������f��j�����V=��Wl��V���lmU t�V����u��K�������,�?����_��7�F��m�n��u�o7;�Nݵ���������=�
��Έ���J,�QOd�Z�%����N�Te<n�����~�~�f�8���|Q�a��%��m��mt@��F3��Wo��[�F�����zg�����u���d�?�������n5s�W$=�du뿬�u�U7��Ճ'��_�Cp��Qn����o7���>���A�/Q�/`�[����r�����5��5ѩ��������-�um��8������\����W�!����3�� _ n4��%W����w�[�Jw��j�ګ��ۭ�ͭZ�Ѵ������?���ײ��V����oI��k���ۭ�N��e�O��ͦ�����
�K�H����'e�ChN������ͧ$x�-� �H�����6�ѓ؄ {��F;����hb�P���P�[��aP
��)sQ�̊aT��%G�q21T�l�,n�h�Ě�H
fYX*���FU*�F,d̬��,fM��矁q�Y�Y|g�b5ό��������������ݰ;����~]���m_�����߶ݬ���G��`%�XT���)3Ѭ�B�2�a ���X�&�A�3�g4��@<�1qy�)�������:xZ91|-�0S8�
7�� � �����N���Ϟz�@�V8X�f��
$��qf|W��*��q`��:E�yp˰6��C�|���΅������_3�w)ھ6���Y��t��������ND�F"��Ǒ������G@
���?���&"�oŋ^�a��O-JP|#M�pG��BEg�xa5��jY�:��&ln2a���6�@��s��������Rd	���K�؜��,N��)���g��!&
xJᄁ�"����#xB��tY�ē$E�.|Cp�(HA�	b7�#�(�^�M��w"���x�
d* D�a�=�`]�1�d�0a���]$"��X�n�=a=�.
}��h�����������0Q���ln�X�_���S�Q�L�dEl0ׯw����$8{�;��
�%B�Hg�0 �gM���/ X���OM��9(!�~q'&�C��c�Ql�"�(A���D�DM�3��P@#D1t����,[��,fogL��@��	f>d2� d�Q,�q�F������T9vdp��	8�}���!9<@իT�tg _���c��c�mŧ�l�V˩,!Mo8����u�apzA����.�Sw���Z����Q��Z�m$�$���S	o�z�jR�<����f�<	��q:	Xʀ)cK��#��u'��9[��l��{������g�L���JY%�/fYAh�?�S�+��04C��2p}�Ǌ?����������>�FҔ*W�T��-\���
B~�DGw�<�������/��NT@�A~��t;� 5'���j!8��V����0��X��;�́"G��D*�Aݛ�D)�A�"�~0�	G���o�������&�A�.�
�9ߕ&���Z�mZn4CZ�ӫX��n�6��>
�jI27�[�.��W(h�{��tKS�c�&���3��BW��7���^�+ǇE$���(�9���DQvC���bu��N�o���D*�n=
 +�z�s�F���c\bF�x����{��{�i��ZX��$ 	����������'�/Ǔ�C�G@w4�J��z��{���D';}@�
�_8#eϩ���j?~���R:Bx���vX�I<زv]X�]��
���v��8�����϶�F���x��N��$/�����1��.Ipi<��*�'��%�x֎�#0D=bV�Jfݗ���)6�6
l�ɇ�-ХC
؟�6�Pg�0K�r�T�?�"L�@ዀ���	&(9#��E ��)0��$6�|8Rr(n�!&�Q�� ��2��"J�Vѳ�G[��0Q�i�&�4e$"��6��D�N8~�w��M��aȍ�=�C	
��ЇI�̮�$�2�⨼��O�	*�$�����1N#P2LU�'�H��+�7(!�H���J:H�-��!��80W�{�g|f��v�2�oVL����ý����-����ϋ�Z��g���2m=k�r�s�o�?�͸�;�=v���Z����BC�'���ڀZ�p�:��X��0�.�E�&v"B\À��u��*�N��@�s(㩵�=��,� ;-C� Z/_�4-��
�z
������S�%��/�*K
��n��x\ue�Je���Fdǳ��Q|}�
E1��Mz�Kk�I5U�h��RC��c�k����?}.����;��9�ϯ���_�����n6W�߮���~���^8�F�p�
�/HR%��tX��oC
B�Ѻl0��� ������(]�\�<���a�kT�^���O`�%e?��6.���"���K�}p���<�SJ�����2�u7���x��� a�{;ث�ͫ��`���+�D�Z���4�s�?0!�V�S=#�'��~�{��si^�����v�m��7�ݐP%%�xF�+b�%MY8�:�H�L�b�p�N�V�(lo���]PF �����:я� ��/��
*&s��ݢ�@5|K>��_3��GOW��|�?*� ��;��(�A��I�ߟ*d~� �����7�q.�Qh>�I�E�.6w8!��R�1H���p)*���c/8V_���>�e�2�W�R�Hz�Ʌ�7�\h��"2�WUB�>��m`j�ͣ�q�̪d��3�`�\(/�ο��:ʁM`]�+i�D:v<�`�7�;��!�k�v�
G!����~�[�~.����#������&��G+ݩЩB�I6$��@��d�G���qq
M���[al�A�QV�w�# o�?�8f�7	9=I�o޻�	7/��H+�
č����S��Й��"�����x��Od�]e�F�� �$�w�vFtC����)�JQ�s�tR,u���,"	�R���?J��E���Z��wx
n��%����%����.��4���d���3&�A�sF�b�ϓ���J@&�Y���M$�΋D)4��4�O�"D��`~���T����x�!,�I�M*nc�ڭ�Y����m�E�P$���C
f"���������@jHYQ��I]�C�Qx^ �mF�	�g@
����D��:/߃��@�A7$��lb+@xE[��G�Y����2�Y0@�ϋ/�e 2t-#k+�,�����E��W�x�o�j�R�����:��_�?���P����{��j�)���Z�.��}��w ��A�Hpp=h8m�g-|3�.�5{8\6��i���g@D���!�i�8H끓� P�)�"g'xO~a�*��2�onJ�4��X3��!{�!}���/g����a��VRk�(�8�P۪U�Hm��ۅ���+F�x�cE@�兜K������	��jR���#�F���a1�=��Zv�S.�&�������p�2]EB�l�������W�6�?)t:M��SH�}j]��wn����t=���B��G�����
��j~�T�����!J���H�N`l@�`��p�(�Ÿ�IX14l��|𑷺���,kM4� :���(F8$,���]��ۑj�����!:�녾#���V K%�{�'T��q�Qrvl�,�*�����-?05��$��S���[��g���R����uI%>�`X��>*���/�����8;��
��z'Aoh?�L�|�1 ���� -� 9L���%�+�p��K۬��JAU	�Q�9�r�f+9�����٠W��Aj��ח����t��!}�g��J���o
���Dfh<Pj׮q���枭��F��W_��h�%���O��j�U�	���{�͗~������J���C��F�2��Y���&�l.�BêT�
��fI(A��H�d8{��0J63�b�
��@{�E�pKB_��C���i���p���\�&��"C��jY�-�\G�d�I-D�����BZs̈wI\��:�]	&�95�{B�-�	zǮ;�ooU[ۍ}�жL&�����N<.�:|�wU�M����*�BBY��8N�����.%�{�� �%D�(�Ľ��'�<B�(�8�)$D�	���
s�B�164�2X�� ��U8o���y�dAfL8^��t"z�+"Y��1�
��(��W!�^f�Oj���)�'��/y�,TȥM���$�D�ec4�1��*��K�T)�� ���q#"q����T���x�2��+�Bi��Xe�Co5�/Ѥ���
�Զ�W)W��N�ը�j�Zg(���[xC��?
�3����Q��/h��\��J􂺓��Dϋ۔"��SaV��3o��[���ə4p5|��\��?���9��{N=�u���G�u�pt_�9,|pzJ��tY�9l Ǔ[wnp��y��9~p�.�[�㳓i��'l-x���y!���3��=���n:wXX@4y�K¾N�V�]wJF,- �&��R]w�D����{ߝ����'m�f���L���A�{�m�,ur.�-�l��o�h�_���-sW��#��_�1S{��o/&�|4�ɬ�/w����8x/x�u���y�J��ۏ��7��.���W�N>6-;;����YA�\7��?�+4:X�Yf�;dF��6�lۗ
�~j�𥷦W:��{�a����'G|5{�U��#;����}C&�r��t�[�j�X0J����eî�^�����U�i�m��i�w�B������G��_`ͬ<t��ȣ��h�3��Iwv0�c��~OI�~��D��J��n��Y+o6=�w|���t�<�6Y��a �t?�&y��M�J2W�r4�ζ�_|f\����S����i��w���[�_�-� � n*v���_p��V*C�_����?�ڐ�������k�۫���UZ��?��׎����\�|\IJ;�R�΃{�(��"��#�b�pN�ċ3�@@��<�2�X�L��/#�X G�ėJS:,�4�� %��b�=v�M��[����~B2j�(�`�!���m��`0�~��TJ](��>���J5�������W����i��_���j�SU�FePhMF-����YaR,hTr�IΩ�f������tϵ{�.s�<N�V��\葊�t���rZہ���R�	�$�IT�^��wE�T�T�}�z��g��L��,"'�e7�vQ�Nݽ�ZeT�� �tr��dT��I��j8�ɢU�u&3ǢE�U�*�U��R\�=6[2��ВZ��iU��
��4�f��`6�X�Z��)��-N34UX��c��!��L�ځ�lD0�F�4k�(Srr�܀�^��Y�֨�r&��\&�@]��?��;=�Gt�W���X�Zy�DQ��0"���YoV����Ѭ�[4J�Rn2���Q��L�n� a��a����DU�gu�I��h4:����*X�Io2i��ʢ����d�򧍨#~X����FR1jv���� ��Z����B�H�}����W_��+����
���!�:�S�t�N�����;�;��\��F6U>�W�5j��?�U������y�.CR �i4������Ml*;���R���'����yPE�X�S��_U��Q�}0�U�wq��$�2Ȋ�ף��R��,�:�N*�F��4JR[-*�A��Ԁ�O!��th���+U���ڷ��Eg�)4�S
R����Y��̔�]7�{����Ƭ���^+�u�ѥ[��ܜ�L���M�����ޓ��6�έ3�gݚ~��9#]鱭����;�)|��Mu��u��7J��uGۏ�o�?\u�`F���O��sZ��'Z[�|��?�
n�crk6�v�-�7��@lO�mu�����)}N����E,�0k�l���p���c���Vc1���m�d�x�ԝޫIy��%�Ź�:��g4V��tk���͡l��;]���w�	d4ۯ���N�U�U2N��5�=U%�?�����5��)�C��S�DW��P��ګ�u�q�بY�#P��l�cE����ه��]�нj\G�$U����mX�쥎1����Fw-{֍�Ԋ��^�89	��e�h~��=���p���4������c�g���A��<��7�F-o|I��O�{�2����j�t�ak�ژ���ن�p#�ܖ�s����e����i��Q�$0kw��G&G��"Bq��$_�;N{�K���B���e%�`�p�F�bӓNЭeswr_�n���Qi�ͼag�]�f����ļ�k��f3H�z�I��ʩl��{Ǆ��Z�����$/$�?X�+�Am�k��A[���-�G�����X��/��
�����?��[���������_)�������P����u���_�7��>i�Ћʽ�薾2��`�1�?��e�diy��ѵ�]5�Ս�Qe5�g*�J��J]x�:���~�YdST���(�s��-^����Q=����	�K=���N܏lY+iC�e8�h�}�N��b|�vQ��
���Yʺ�n�A꠬��1��r��J�RH����H @!�!�B�Q �Ɠ�$��_�����G���� �����������Pإ�|�w��/-��k�q�����h��)�y])�Ee�7����<��9%�Jw�z�ΗQ��1�h�k�s�uh����c�=�/��F�}2�;��q���%���k�	������L9R�3?X��Y)!$4��*$2&62��%J��ԅ�*����n����Ʈ�~#s���֧>1u�5>1sOy��ʇ-o�l4���1�7�󻔫&������s4�s����(��âҟ36+9]|�ĸ�μw��a�Ҁb����M�,KϗG'?�/�<4���01� �������.����$j /^:ǃ8"	@*��p��&�8�/������K�~�g���/� I������C�Rڿ�� �Y�?���*���J[	
�K?O▂J����$<�UN�R�5�ؚ���CL�1�?�+:����Ǖ[�>t��m�p��@Q+#��L����Zk
�ʖ�v(��7�˻�Q�GD�$�}߼�)T&r�j����r�"-��&x�g���=�V�{�̹�]ၨ��?�Q�V�f|r\E�t���-���p,D�d�AD�œh<
Eh @Fa�����C ,����������EH� z�Ǉ��������ǀ���cа�W5�cє�!�#�g�b?��H�N����U��F���[;�6��i-���	����&�=vq"��}&6>���,�
U���e���@�G�(��#�&�����Bw9�����6��������q�������҉�T7g@�[�u #��w���9}�v?�� &B�H2a&@��*��nrxG��6b9��RW�.�L��"[�ͺ���_�9��+r��AԈ�t�@ϋC_ӷw�S�9$�c�e���M YMů�ЙS���!��w������B �i�b�8�	�B���X*�J�� ������ Xx��j����A��` ����������?
D/�qy���*�׮(�7D��T�32��d,���q��-��b�d �$2�P�D��	T�B^HD�D&�V��_2�����������x��`���������?�Z�?
��`��f������ʁ���C�1DZI6����}�=����s7�'��ѵ�؝8pvW ���ł��5�>�5N6�����	.Ϭ��(����C�%�uD)�vj���c�Q�GU�<k��kh�^���y���/Kk,�圄�x�����k�����g�m!�D=y�O�\��a 2���a�8�F!�T ��R�ma�pd��+�?
-��@|�������_)�������_���A������z}ΧƜNr?����qv�d5�6�==�h���
�����g_�=�Hc��4�1������E��qZ[�2�Q��<��X���&�>��E"y��	�&J�	���n��'y�����
T<�Z�Rc��h�U�K8E�g�(�dϖL۬8٦��,wCS��lΗ̜���Z��W�G�D�%��埣�%
�٥�4�ЅY�5��>zӃp��c^Ὦ�ru�y���Ei�zg⢽x�w�~�1e��|�ߔ��J^�RR����S��!��o���8Nc�7��e"M�?6ۣ'��C�!�Օ/EhL��N�����<�֞)j��]�^/z�7Kw�f�GVA�R#z�l[��2+����<�M�N?��6�}
�!�����Ji��,�������V��
��Z |=_I�"9ǣ�Q���
�l���F�n,�r��8��/��<�����U��K���f7�5Y�$��,d+ƾ��%[BE�d��	ٳ��T�)c�"c�n^������w��t���<s�7���s}��y����H��OFN�\ж��%�����{�?�h��ۋ�6 �@�a��� p,�B���������3�_������m�#������Y�������_9s�ׯ��Ĝ�8�ɢH�5{,���m��emW�'�\�sJ�Ә�O�30Iw�O���S��%����m���G?j���z��-��&�B��-����b��Oϟ�#�KC~��K�%=��"���\�\:tf�;��̺�E��Q��;����U�_�F)�2��[�����o���A����`(�AH�-#D�Bؿ�������?C����������������8����H��������#� y�핾N�	�z'z�;ϡM'�K�%:%=���=�
���Iy ���Ҙ�������� �,�-�Bq�r(���!@��-����A����i�Ƿ� �������������Y�\�!�?�� �1�~����_5�[��dNήj�=��|�(�:������9����N����?�>��M��h2$�<�.*_Tw=�a���h�ҧ}�%�$q���>��$���"�I�ڒ������e������	����B@0�-�� �P�-.�E`�8�u�c�\dK/�J��2�L�g������,�?�� П�?����K���X �MM�����R|����鉠/��H�@�G�bD^d��hh�K�� ��$/�^��!�	��<K�`!�w�Q���4d���!8,�Fm]�@�c�(�-C�?�����`��g�?����,�?������� �������a�W�3Ǻ������Lh��DP�N�v�2�2�^4Ŀ�V�:��gS��x��+�����|ߦ%��^��A���M��	A�p�usH�����L����w���
��p
(�)���q��"�O�_$|��훙���9�%eV'1����Cxꦓ>���U�q�;:K{�5�j{��U
����U�x��$�(��gq��j��_�i�s��ٌ�"j��>���\�Îe����XA�Z{���vg�0�ۅ�����W[�&m�.M��ؒzu�\|'T���xi��};�FWH�o�u����V�{v����a��A� U
�l�
떉r�����7�;���($����kǶ~٘5��7�%Q,��-���=��M�>�O��^X�2���O�^C%cei�19D�sAJX33��Uj
Uh�Z��r"b7��l�
�sG���lϚ�ӳ�/�ӟT�v�v��zds��f��n'E?v�c�� rQ:���j��}����#/=oF��?e�}͝��'��?��4Θ���-�0ݚ��#�����$<x1���LP������TJ��B��℧~ŀQ�R�E�vm�	i}��\�/R�~�ے��`���;}
��V��K��p�j8DN�-����c������9�]nx'�(��o�XQ���vɵ2:�9��2�����qg�r�`x�D�ObI���/����<�\]���c�7�a1�.��ͯ�g�N-W̨�&_el�)�3��F�-;4��{/���E����^QV0�U�]��@�Q
�X���Y��)��:���L��
?���pq�B(�x_~JC(�x$��a�k���[G8ǌ��0�18/aű���o�/�7���]r%ϕ|�H]���WV]3%^H�u�͙j��'UP�=�F[�������|Ǣ�×�30�k��܇�/Y>[�ٸM臈�1 �i���CAD����*k+���������އ{�����h�����K9O����[,�Z=
�k�t�սa��!Y�K��o^�S���\�����H��!�}� ��l�j��Uf>ʡ�=sjbXCJe����#Ȉ>И?�Zm�g�H#%Ŕ�f~(�1���#*��C.T��r��Y�%D\��n�rw)���$�ҝ��;xV{
^�љ&�ޣ�F|��]�(Fr9�J��Q0�M�$m�^��ʻ]�t�X�Sq��|���p^v�5��Mue�X؍��kj+�-��'�3�}V�n����=}?�z�"�=�?��1��DQ�
i�oG�������1ɺ��3���0��d >؛�c�s�aI�p�I�B�ujJ������*`��ױ��M��;����{.��^MԁB��H~�ll���PJǱ䡇��Ѫ']��l�3Ώt�E�8A�?�����-~#/���
�^4<��R���<Z�i~�IK�'��;JnG<�e�#�;���ֱQ��%u� I[�p;X�U�xI;�����5˻���}�N%�@!K�9y4�~[�M��6q��y�T)����9$�%�8B���5�����
�t/ʺ�<���U�B�d%���W�~�P�b�GiO�ڜ��lj
�v�/ઃT*!�X���o�*'���~	_��'�R�/˗����+u�,.�fTx��7�.��rj(O%�5Ҏ�*
*�;�Z&�'����I1-4��0�{�<�g�ݯ��p����&;X��@��X��y�ĉ��ή��3��
f|�s��$���ɤMݿV�FM{i��$��x�P�|�6��|\h�|LE2�/4����3p�cە9�<+�B��SB��G�3g�^֨
J�[�m����9���D�F��4�<Zey��޷S2�
A�
Hi
�tBB9қ�й���?�y�����;��ٙgw��ٙ��~w��y�V�vn�He�gg��d�>l����L9\KO�P��*$3H,�/�2�L@Sj�jqn��_�D9�Z�2���:�O�E����^������f�O0|I�b+S�+`�?X5}̒
9�q��G�T}Vq��E�׹�!\�j�i��E�t��{�0z��g�;��6t(�x���àw�9��R���4<�e��lQl�+�G�~�ğ���m��� ���,	� ��H�=D�b����A �l�?\��C����������
d6GYh��N�]�M� >�n$�׮no��P�4���G�\���q�Ք�U~*̐Zm���up;��ܫŭ�f���pk��4J�t�/N��Ƴm�uҁ�ɬ:���>�)��Y����X�'=���ZI�3"La̡"�C�fm��",��h�A��w��xqł
ǤǵDe>�`I%�h�V?�������yK�X?gS�(W��x
>-[P�`�sV4��U�Y)�2� ��r&iMS�K���3#��Nkq�\SI,S��睖Tn��T͗��
X]���ܞ\�������iZ���V�ZLd~0a*����w����͸��q0�����Eϯ�>J
$W�dh�^��*ߴ{p��E�-z���:&f�'@�_��z�F�ZT_�����0w��Q{�݉�[�"�f
B":l�6$#��:�#���O$�޳���a�30�}�������
��>'@�v�X?P�߿C�<�(C��`���
<m�I8�oN=[���+a��f��~��3���	ܭ0�3�Y��y�ٽo�$�ۈ��O����b��&��X:�x��esTH� 
U?�?4��l��	�XW<��x��� ,ğ�=[|e����	��,���db]B�q�W�1�[�"� �4QU��b�v�CUx���O��ٺ����(WB�5��F��"�"�����A%�śG�O���&_�Y��6���/�ecS&G�K��vK��`͚g�j�c���qgd'�|����t->j1
:`�l���sC��6rp\�_
�g�s��?�yv�����^�<>������Ox���Ă���m����M�ir�߀���,���
#�qH6���3,%�P2lA"�����mO�y���Kei1�zD��a��+|y5��e�`�#� �ƹӥ�	*�k���Q\N�Bm4~\#2��S`����_
���<��q�û��_qeu�6Nz��JH�	+�=��0���7����Fy�U�w��Z�#��א���0�J��=.��x��j`�C!ӫ]s��Y���*;��v.@:?��}&��?�(x��k3�u���pj#����*�x�a&O����G���C�q&&lEBלo��2��apO�ª#���in�k0�;�B��/���w`�8凞ƚ�����mS����)��^}�\�Z�/k��8�X��D�X�8���jl����Å�fh�t��x�I�tL����ލ�nq����xx��~~{��X��"��WZ����ڎ�ѾJa�2�HH��Ds�|8>�@�i�|)��r���O���w����lM��WY6v/
g��zD��~���ݫڙ���w4��2���"k�E8�}{�"�pI,���K2d�{��)-��nɼh��I�Ki�y�w�_e0y��$�ǰ��{�85zTi�+���s2l>��j_@�TKȹC��gp��Ǹ��j���[M߿��E��_���D���H���������<ˢPcl����!O��F�*�U2�����$�!�[!�
H5��4*� ���H�.�M��UZ���3sq�>�b�8�3�u�_�����������'Lņ��Ǒ��a��i�q!}�o�>��J��M�3�.���p��'jcgg|�4���2��;�%�����S9$t�HH2q&�[�μ��:��A�I���=?�K�̣��D��r����LIW�9C�m,�t�ZFw	Hv��87��K���~�ԧa��r�ҥPw���:�_�X�/%.�1̡�v�r�)4�֍;�`���Ҥ?��
2��p>��q�4i8ܡr�s�k P-q�j���n'"��ܛj|N\6ϥ�չ#��C�G�խ�*���U�Kq��SZ4���u#G���B����ē������
�y�����)�5Ф�Ji:t��[����U�Uk0�@�g��'�+1/��Tw}����������C3N����5��M���P-�>0��^���F��Ռ/<N(P�YXcն{�B	���P,�Ӹ,_�7�i�	� �ļ�V�WF�'�6�j���˸Q��%ٛ{��뮨wō:�[�������i�py|~��պ�ϔQs
T�	��tɈ�T��Ґ���eK�.�q��I��Rڲ<�H�����������эM���<=\�
�Z�-���N���<8�'����Y�9�D�d�����,���GWؼ'vl�<l�����ф~��K#�"3��xgE�[��J��v�Hq�@�4M}������oB�^�`�R��������U��gj�@RY�L������\���D:�C]R%v�k�S*���8%i��lڿ~��'�"fnN��a?.���8�9�������00G�[X�~&���ߑp�v��W����������������(���#��������������_��-�Y�-�goEdM��v	P"�Ա���݆��!���� �4F���h<����-Glm`����-�?]���!���~��o�����?F#Qh�
��b�����|�����`T���	���ʹ�o���戟^I�?��8��$��C�c�#��:��&J�I��ѕe{t��`܈u��3�̾#��)�Y�o��_:��7V�FY\�y���ɡ{�����
71ՇIՇ����c]�
.<iRp2���X`Y��o1��;e$�˱Z�g���~�I�{�݈�^��G��a>�g裛����8<O�[O�.)0�H�	��Q����PfO�|v���o�f<�n/ݬY�r%�ٌ��j�=o=��;�晕.;�ގ��؍��f����+u���z\��l�ߌ�q�-�Z��w<�#���)!w8)M8^�x�L̺7�$��]���n��J׆�%��F��&�pIZ��'�d�-x����EѶ2�#��K*���b�f4����F��YA5�4х���p��H�7�=6?[6�rmrD㉐�Aʸ�]d���P�-�%4R�Г��:~���~�Lh�R	����	b��тq:A�L��a�i���r1H��E�C�"�x�C�x�vacvD�;���+�#��'y=H����7�!��3P̃"����>v�`+J	��f=��N�3��P5� �d�0u�	>���Ol�u��tez
�|��K�	��W����������L@�Qѷ����Xi�m�O��LU�}aE�2<�ײe֑�Jb��~�$p�J�!�M�֖�8%r��f���� MMrV��b�Y,zv]�g5U^r���E����� �d�J�o&3 ���S2��e.�����C�l�7,}=�)�tx�~���x`�bݪ�Y��� O�u�'p�]fs��ں~��O
=Ϸ�剜yY�����r��ې�n5Uj���P����u�Գ9��X���:ڈeT[F׎�Z�j�.��}�	zSF�eQ�}Ň3�{�q�+]wK�����L.����-d D�-!F6Ҏ�f���t~]%W���NЃ/�:�+�Q$6��}lE���d�p�#ys�.X-aC+|[,u��Z<VL�Z�$�Iss[�ٞ�׃d��ɝؐb��q���jo��i^;m|Sz��Q���_�
&0Ȋ�h��,㸻,
nko��
w*n�($l�����c�?��EOޔe��~�$)�:�IF��?�n-HZ��QO�*���<�}w��G��5P$���T��>��.�qM�g�z���t��(B��ξ�è�N��eC��t���n�������2�FRP;7�9I"�J|���<�FgY魜7��Ԛ�h���/#�$����}��h,lQG����
Ҽ�p�Nb�j�Q>�C�4�UMxC%�8��}��-,PCB�)����j���`^ŉa�it	�=�=��Ϣ�c+��ZD{%gw0a15P�K�w�vQ�n!�c[UdqP��эd���l��"t)���� Wi�k�VG������E��<��W�]S30��8+�������Sur<6�ݎO��xr����}����7vZA�)C�_�J�{�OyX�����D���|�^��x�>UbS��21Pzrd�;�+AM^lrvj�V9�E�o1�bG���>����r4,-k�L��0W����B��\y��֬�RF�u��d������"d+���-0���L���c��w���$o)�dcG����y�8������wlF��h��wZ��^�ʰƊ//ںz���!e."�[�:[���Yx�f�d��Vf�d.t��v����������+��i�ɮ���ч�iu����kb��97�ԕ�N�Xt7���4�'��&�1�04��q:����4A�51��X��{��DK���0�Q/��>k�Ɣ�������f�Zj���E}c�U�O�l� �R������B�~��=�{����j/g���;%��ZX�E-s�0a�]-��GY���J��C�I�s�z��^��Z��YƇq��_ů�&Z�Ɓ����<��M�$�ރ}VP*z���n�,�fq����������.�)z�
ӥ���
Ȅ0���6OCIr�z�3w��-�eȂ7y+_JN�̲H6��c�0շ�G'*�V*�������+��%1�YFH��t����V&�ʳ�q�d
���H�
)�^Zۼd��������e�G.��۳[�?��"��؏b8֣�ex�f����@�Y7�ޡ��� �
�.�f�]�yb5^�v%��u�0�J�l�v٢O ���w���?��@ � �VT ���0���� ��p��?��@�I����'�����?���O����O���?d�o6�Q#����㚨��էN�O�X����%��Z]}YA��ɿ�f��lJ�;��8ȃ:#�����hXL���%��!s��'l{�����jΎ+�z�=9Q��������� j��A��^@Y��M�(�E,�{1ș�A���RC�N�L���*��d�͑JgN�JW
7��� B"h�h�i�h �>���Sv����/<�F�����,���\��(g�a4�k#���/VpxǴg�x
�s��h��Ț�7��1�c���d�	�V��z�LBFu�� ���3�5J����5�ԯaY��%��h�i�:��YxC�y����x�|83%^����	6�1�x�vt��4��E�Q\�ٛ��5(���Ț��wU�kʩӫ6��]9�o�ee�-���&+k��
B�;�u6���u�_��*inuB_仩�CY)=��q<6�]/e���P��[-�S�����![�3MѳS��L��Y:��8��\
Ol�"d/�&ԫ�MTf���Vbj�Ҕ�f8��+h���NS�ROw�ka��N썺͵\OQ�Hf�\]-h��^�KΦؕ.i�D�1�ai��%�'��'���^��ʴJ���3Q�Vn��گg�wUw�.�`:�����e�l`n, 0��pjH�$5ILIt9�M*Z��\O�D����1�����˥2�ވd��h��T�X�	����M�z�����}ټA����g
��Qr�=�U��3剶�뀴썆�t�,s�5�	�x��7�ق=���3ɷ��s4rrWS�s_�ħ���b���+��.5�-D_��̊(i7Ŝ�`"�uv��%1?ί�a,�ؐQ�Y1����=k���R)I�Z		6c)%Y��H._�;��*/��f� ?[�A˧a��)��/�m9���k������g��M�Ȕ�q�'wsf#_����e���#?���VR��A>7r�t����l�����a���޶�v"z46K��\�� �(iء�g��X�p�z�N�O�#_�7Z�쪯mt�O�v鼦��ǎn^t)�z /`84�ZMw�Su�����M��	>e[�Um���ckl��Tt���nJ珔3��8�3QzS�QF�h˳��';�O�ϵ�p�?���Gp�]=���\C�?%>���RF�%Fs�Ɠ�������fL_�c�5�O��$Igɮ;+���!8��S_�r,|��~��Y79�s��+l��Db��>��G`s��
�R]�#�[_�g,��b����n+�16z���}p1��J�S�E�h�#i�����Y�4��b���r��.������o��T<2��e�# 8�qa��ӭ&���RU'�ѩ�e^y��[2��ϚA/����dW_O��o����Eę�Tڿ#��zm�{��lX.�1#���מM[�H+(�*z���n��=�D��D�Ie܅
l�����?�0��qo^���4�߹b�+}X���>��o�}@�˶�&iD)A��SADBB�Mm��A@B�;$��DZ:�E:�����8z߻��w���˧���5kb�5�� ���V���(M��ѻ�4I��N����/�ww�b>����z��Ԥ�dY���Sq�諍�k{�a���v�# ��A����fۋ��`5
�U�_Qsj��sLv���k&Tf僥LKdwI�+'p�=��s��5��}N�p�Ux��iH��K^�
6�ƴ���䖝�>[a޲��43~��U���bZG�|�C�T�3s�\��{��C�^LKzJ��q";�~�C�%�h��Y��0�1i��x��Y�/^�+�噸} �dy�=Z���I�_0����_͖;Ҡ�@K�ps�S�Q=��1�`C㦫b�ޖ���~����o�L���� G�0$N_RJ�����n�I�Ɲ�e�I�������֜��s�|�g�����\5{��S�:�:G�ͮ�L�e~�������3!�*�����H,F]c��C/�����'���of8E��r*
���,LFY+1O�n�ՅK���6����L~~~N���ȖTc�0�e��m��Y[jm.`ͪ��suT�C�BQa�>o+���u����w���-�1�w�G������[(m�dL¶��'v�uF�� G�Ei���US��d�=�M�V���Z�G0.U}N�<d)��F�H�N[��6��cV=��
���-$ܫ�P��R�䳊��Z�`�ǰ�����'�� ���h4��ɝI���*����;�l+/�Z��
|x�eQud��B��ѵ���,���Lo[�4���XR�5���
�oj
���miF����[R����
���~]���M��k��YL�6��g��Bq�;��+n5
_b��X�������"}�����L23���!�v�R3�Q�L�ahylh,���m���h��&�x{O�Y��N���AUEF�NNc|SJ�I-���x�������יX��� �
`�.T�X��Ŧ%Ɓp�7Ј��w���U�+�U6�D��|��^$��,y�@J�@�if�/�Zj�q�#���%�ޭ2��ؗ�U���#��my�N�A�6d}/�����$2�e3�H.9�\Ը��G�Q��3������y�2Ɵ�mL5��Mmf��#�lY���64��z�����'X6p��S)z��[4B��n�-��p�Dʾ�]��fz�OQ�^Q3���:n��s����vQË-�����(�����a�����@�l���Y�����ͤ���L�X�
$)'���ee�YbX%��[�mة{�n�
9�1ADoŢɐ�o�B�˒���l|"��o[M�������V��)M�@E�5V-��z�6d˰�rDH1�^W]EBiY�)�.#��;�rE�噽�ų�#�e"D��E�v��>����i�o�S��t�X�L^�	)��,t�(Z����x�<_�$O��m��d^�A�X�펧F��Wk�V�ޏ��!��KtsM�bp'!?v��%��ˣZ\�m�� 	�XƲ���ߖ�nj��
�����X( k��xe]�^�
�;c{���P}�\��8�֐�(�Z�a]��/����$Tz�%��B�B�@$�ǁ�M���ם��V�k���.�<Żc����0�m���7���&�E0��w�p�B0&�B���y�M;k���U�/b��)4�YCB��)�)+
�̦8z�@d��@�G��S/8$}��6gC�ڃ�8Pa��}�*G�)\>I�̕]b^:A�o��d�k��})ȉ�g���X�d9}�,4}:�U��!]��pp�}�gF���=�ky�oh����Ч�뭨B���|;Tw
d`[�|����H���f�ͮ��B
3$��FOb�pc�}�#)��+��x��M��bc�
$�1�+��j�{�<r��Wm�7��i���E�p;��0�T�/���ƫOlGEƁn;(��Ĝ���Tq�x�����k��5SP���)V��8�H%\��v�9��`�yDŨK����S���\O��������Mn,�)��\�}���m>�4�-UTV1�q�:��!���ur����+�d9���%�/e��Q�����i�!��/�(�O۔a6!o8h�y]�?�u�_��j��_H6������%�v�&GT�ۻ�ڦ�v�2�a�N��p��
SG�`A-=-;��,����"�&�8i
,����op�
&<ٳ����x��%�>K��Lټxc�x���}Q�ja)���ҋ*i�M�P��*�sUz�
&�;2I���]La$��v�����c�G둔i���ք{dԞ}k�~)\X���E��l%?Q��BԌ��l�B�0�4_��������NJ�Z}��ށ�	�?I0Zn�hm'�"�+�6�-�η��:y����X
+�"���n��a�MH�p�I�%X �۶:q��0L9����ZVe.<��w,��-D���D2 g􅇭4o���ۥY���7�⨿����#���Mi�qz��۷ ���lBy?Ef����E�P�J�k��}ﲟ�?��B�P���r��e�6!���t�mb�z��*�=�i�YX�7F�MG$� ��6�4��	�X�ᱻ�q��N���f	EP�������|PFXɃ�_�*c^�y6�.}�D9��{x]�}==��!f�kA����� M�S�t���{�r}�svvq�J�Yz?mu�u9��څ���r�C��]�*#	*���O-�a����;�%i�ˏ={�F�;b�o���_���F��,S��e$X��Z��mnA5
�$>c&�u��mA�7���
b�K3Y����u?
��k���uq,26�6g���ҖI-��D�-��l�ަC։���he�\��?8��㪓��ޞ\3��"F&c�VH^sh�$�XP�����
�87�z�#�'�[�w^�7_[��U��a�l$K���p0�ܾ��M��eٗ7b�4����4M{uE�&�:3Tr��x����{��̹ђ�����m:�/Ȩ��*�n�$���3��G'��G�����(�v������W�!@RC���*\�#�3=/(�Il^���>7��?ܩ���,�������V���s .�5+�G�8�9�T��Ω��2|Dja�U;�r�59���B�B]|otg�P��H�0)Vfu��1��wek(�Y0%�r*��7��Դ�f�v��Z�]w6���0jT�Q��E|�eֹ���pd��}�����/���Q>*�����.A���2[`v���&~C�M��;�7�>fXu5�(�E��L���)����PEī��l���=a0͐�W{:�N������h*�����"M�X�$�\[�G�Ez$��w,jUP��'�ĳ{Hd�6:r��y玍��4LJ�Yhzl�<e�����A���0��?=!I�ɭd���l6IO��7|��Sõ-���C�>�g����s=�*�s��Q��|`X^���v��~X�?�eiA��C=�xW�8e[8�t�-�s���n��C
Y��|����q��R
o�϶_ӽ��0����Uj�H�ߛ|8Q����˰�U'��\�Q�����U&��]7rW�1k\e����Ȃ�d�K;b�_:0ˤ;f[|��H���ܗ�MÁ.�Y�>��E�R�	ZJ�b�� Ӄ6:���W�,��K�J�.q�RϚ͒L�X��$�C�8�oU?����ե�o� 3"`:�D�;F�U���꾳�@S����A�������v�Q.�]s,����3��h{{W\��?�*E���W�m_[!�����y�A�ͪ����a�Hݖ�Δ�$��ǓH��ӡ�.�ӽn�����F�G���E�S�dI�j��w�X�;�7#v������C��^v�z澇=ƎwD�O�������1#k7��r�Z�kZ>�s��"��]����Λ#B��{ԾK�bK\Uے�2N]�{�����<��E�g�w3�[M�6i�p����3��ooI++L��r���uY� �z����:��ػt��*�n$W�QDĎ�w��ƚU�t3������
O��+�U��Qܸ8]���gj�'u���|���wW��?��N�~�C�9����l�l�����IZ��� W��9t��F/�����"�(s>��6&��A�1U����=����)��cutl�YeO��Y���x#˦s�
���I�vPu_D����#ںx��:�����in�=�XRƞ�w�0!�QH}��`�
�!��: ���HC�Xc��|V���uY���d{o�iI`n�H�R�G4�z��!,�-yAify~i��+bMw�k�jI7mP�"U����yoR3�3J���^������kɚ�U���l^qr��v^����*~8�mV_��TW�^�].��� �a6*�2s)|�)[$�ua���I�99`�XV%x(Vf��7Z��}�Yu�/��+<�0�:�������jDP�(���� L3^[̄�����8��(8��XȰP�#�[��͹�>� M!�EK)c1�$���u��8��HT�;Zy�a	�I(�Z͌'Ƈ݅vJ�JV��~�l���'�C���o|�No��N���lw+#����
�"�6���)�l��5J���@{
�=��*��}���1��ۭ���Y����qr듅�Y�'��u"!w���3�Ԓ�.<�����&o�*C�	K1=<S�׋`ߜ��;�(G���땡�T���Z�L>.hLN��E����	�{"��%�����_�˺rGd���'�s�G�{m����Q��uh��=ؼZ�Ǖ��R��qυ�:��a��LSm�����"K��͞T٧��\�l� a96��ꈫ� �\��6ٲk6�*��ujZzG����+������3k`bF�먘̥�Y�r@�>]y����rɯ<����h�i0 ��D���h
a,f�0(z���"f]�M�e�}���>7�T�ɴ�\?��:��ue㒯w3v�g^b�z��LH+5=+�C$+�kZJ-�λ��V��M��g{+r�g���D���,�Ҏ�
��Т�
��T�n������wTf��|i�ׅ]�\{�?���*Eݯ&�TP��'�z5�G]fuz���*�m����H��,4�Ë�6<;�&�;U�r"6�=�|U��dhc���|	���f��	���淤;�e�#9�E�� �8s���U��+�oqM�Fy,�>,��/w(�<�z*�0����Oab!��
��5�?��aY �kD�0�ײX�q����.m,89�r��9Z�p��5���厾V�bT0%*s7�K��h1M/J�N���L���-��>�}��|����^W\��P�1��r��v��~rh6/��Vbo���+ܮTR�z��B��%ΐ� �iN�ww��A�A�0)�����=�b���y���1��a��[�;Ż���V�{�Tw����w�������~�'�5��������[���2:���805^.�"���*>(����Mi@
���X�.4*�L����cߗ�΅J���� H*mW�
�b���4 YۍVm���H����"D�om��\��=�C&$Ao��C�l���-)�+&�8�,��׿Mk�O���_]�x�'�qo=E����C�~N�&G�{/_��}ǖ�:�)��
N�$Ekh���@(� "���ql�:�|��w
�җ���|�cO��+�s(������qjǺi+�
rQ���`�b��Ρ;rX���R�>�(擸�q8�n��&Z?��8�k���"`��dT���+�K8e�d%���I���~x�$�Ғ�[�B�~>�K>
�����Vg�K�G#g�_3� �2�K��2kp��ʇ�e�U:2I9�e����<�
[�8���(��$E���
O�G����a���mc����@�ءR	�1�%�*�k,��E��T 44@�XZWil��	)���u*Ʋtw"���Vx�c$���[ ��y�~<Z��4�Ȝ��ew�>>`����N�h �@B"tï�����7E�I��y�
F�|�]������sC�滔�t-j����>_o�6Dg����\Gx��}+:���f���<I@���&�=�f�j
"��za��V̽��U�8L�S~�^�l>���޿��gG���b���0P�(s�����A蝥���A�n>��<>\��W����_�c��7�����i�p����ϐ5�:6|0����Ȃ��i*��-Cr�kjI'eo���v�tk�飋m�T��ߣ�1�X�Q��Z�����3l�ft������EK�oR���M�<�Z��w���hޠ��h'[tQ������l!=�o�Ġ�o�s���OT�\ֶ\��7Hk�K�M��G_$d���1��u�^虩�����usc&�ȷ+\Ǣ�ҩ��h��kF\蒧����')�c#*S��#w��H�`��U��^3�ɴ�Ma�ɰ`���_����6^4��l��#�Rf��­j:I��S7!|W�o�]>-(+ 
�P�[	iT�G|��.��1�!��L؆�u�f��[�|7{��0���H7k���}����Ó���y�l8
"�/�O�.i���eD�/��:���P`�I��B週�s�����#õ&�fl_�6�n>n
�T�b��"��g���k
�0�����AZz�`�s���>�����V���h�h��V���!���>=������2��/�U�c�f8�Y�<T��dݠsKdE��?�D�&	���;��_~Q5�;�D�hɦ�W�$�Ũ5|�<b�.N�Hi��|�a��c�Y��I�ޱ&nw��v7v���q�G�8A�	���"y����WAX=�5ѽ��Z���2��\Yv��(b�F���/(Ƙr�L~�wLnh�{��z�Q��ۺ��r��A��.�����h��>�k��*�������<(�6ʋE0��Ic�{+;�,�	�|ԃBa�1�������;��*��DGB>xya���<�2~8��B� �BTҟ$މLxc)Ę
�Myo�Н���o�q��������#ҩ�1�#���/����ɲ�L����Ww(wp��?�;t\��k ��7F�Y�t�O��܁[��.*8AX���Z���7
�[�%��0��Ǘ_6}G4n� "�;L��qrn5p[M��i(���̪F��=�n��"�3Z�ke�9��̽߹�i#�g��/��h�g���Y��@Ou�*_����wL�}`!�RIo�Nu�U.��A��՛㰓��A�+GTP�]#m�;`��c�*�A�	*��**a*d���1{|a�۲a�u���dWsP�0
l�|ӗ���ۘ	�^��/�T�n�Ŀƨ<N�*�v-��.��P�^-��S#�Mez��@c3�:ʹxBM�k���ow���t#�<�]G
���
�CVO��q:���S}s��dO������;!<sG;�W.� ԓz	���Ɠ�P���I���>�?�������g��3�ͳrp�C��Ӈ�{V>��g�y|�;�?;�_;�˞�ϪF�3��%���nxG:�����gp�3��~s?���՗g�z'�~V����7�����g�3��3��MU��_ :��~���c^�q�Ϲ"����O �ߋO ����#-���8�G<�<�ǡ9��'��w����q�3�,p\�L<w:/��r&^��L�R���GH�\��!�����&���L�R��x/��3�AH��q\�c���6ó3I���#8`[p���C�q��ƣ��1��G����taB�ҿ����	�!7 0�l����/�;���+0Pi pݐ2� �w��y�^y���'��
�_8}��Oxt㤀R�����E��E��M�E�J0�c'�!m%��V�?�u��5���^������V�m���m�z�>��?�֜?��X�����,���?d���#�;����>GX����� �,����ϝ[�q �����3=:�+�D?�C��a'�����'a�I�i{bO�q����p��T�����OC�t��[(0��x���=<� ;G	[ $�ɒ<>W��N�;�[6���$TjXG�1�o�C����e���h���R�I���6Xw҂i��+��:���1��d{+��*�3m����7��<�ёԚ$o�<_�*�M��S}B�3d���,����T/B��K��u	)��dlRBb����� ��%���$~��_�
@�	�w��ې��1)�cRT��P80쐽=dm��st�Y��0�Z
f@֮��m�3�|�GG��
?l���>8t�?:z
n��qy��1W�Δ�~����+4�?x��;� i�0�N�=.�}-�/�j��`��G��aP��#}��{�{PN�����m�`j`���]7_>���s�\>���s���y~�G#����l}��}��3��y�;Y�a_8�>��<=��
p������.�$��5f�I��3�ӳe���_�����|_;)�~��/�
(�%���?�<~����0`�T/��o��G���;��1~�����ُqL �/q�?a�\��գ���I������؟r'��b�C����:E?t���s��<����Ǳ�֋��:9�܆����]���1�q����v�^8}�N�!��9��:3�P���y^��3�zB_�W��y����g�8�u�M�_���<��M~8i�I~�t�.Щ9�Op�s\������� ������������֍���@'�7t�n����i~�����?������|8�甭]���pq� BC�]�W7�=H���^ԟl'tJ.�7X?���?��gАZ�������k���nп������ַ	АV�b���s:O��*�����~Pa��+]�����[�w�7t^@p�?�I��п
�_�g�����9��t��v������
\�L�iz.�9�vU���@W
���� �$I�x�DO�UM�~���ᐇ��߱�9���������x|�x�W�<�3���@jʦ�8<^(�
��� ��/�B�K=�x�8��I�_���S�\��9�@|3/T|��_��?�3/W31 j*뫁;��dH;O�SHL[MKhfR;;��	��̙�p	��lz����V�#{2
<��?L|*c��
�y"Кj�ĎK��q���`��zZ��Z
���;m��Iy�穧��c�Z��*�tU�۝��C�4/�&0C�N�@t;!�$4�����ڎ����Gv�C�fQQq���52�I2�]V��cv�s:�΀��BK�sQ �s���S}�t9�9�\NQ�������[ݪ�_u�1	�#CgY��g=�:���l�7�+:
%+�)�q�ϲo�p���&�S�at�B�M�e����/m�؀���;0Ϫ��Lyv�rh[�����T+�[����/N��cm:�����
����j��(� ���>>���tYh\�Z�MQv���Ѡ�"�-[�6����8~������8W+�B^� m�;�;�?�У��z�{���f�=t[5�h?M`���0ր�� v��_`=�^�3�#��d��������z�u���(�걒�� ����YS#X.���O0ͩ�}r��
�-Z�+@�~�
�&��x{A([#b�e �C��p�:"X�Ʋ X#T�eDb���<]:6*�5>vD`��/�\W<�ud(k<�֕ ښ.�2�i]#c`Yh�d�2�|]��Ǯ����	 ���C���Z|ݒY�N��^4��[���׃_��Ű��`�Ϋ��!��~+�Ǘ�P�|��\8�����Ş�Z�M��6����I<��h6�Ö�*��7TK�k7�����`1���{C;��bD1��P\�4>�\�������z ]��hk�(���ul�η��D�;�o�mU�����n������d��\
0�����\�t
	��5�_p�`��	�~���7��e�kf���Xj<�RO��`%�o���0|�`"qΚ5�A��b�p�s���(*A�g��b!q�ؚ���3�E���й;����|ن��ጪ+���'����#ac�T����##&�&ɟr�����'B_��5�t�-⿆�=o�����|���ro�}��K��Y������:?�3�<��p^!��̝뼄�����,�W�U�?gNaA���K����ϋ�����?'�Y�4��祿���\UĞ�����>_C�K���<�����VTa5�j�O/%«Z!��cg �V��}后u S���Bh��0�"CX��eDXa��eCr��p%�e��om5/ή-��{2����E4;�o
�;����R^����?��C0����k�+���~Y^w�B^,�	�&�"m��X�1��g��EL���kjv�filtV��G��vM+���I�O���N���{���l�)�F�f��b��mN������aoasõ��6����	�;6�in�;Mp�"��o�V��r�"��rн,�J4%���0ɾ՛][$�]H�F��$)��|��G�5'I��.��y	�i/Dy��1۹�`�K������t�8m{�]"����)J��;����L�=�ö��x��0���${a�j/jMZ̟��Z�ॿdEi:��>�z���� <��*�����#2�N� SV-O�P-f�iv	����~^
�> �q?�m�b2�h)q-���'�U��
����
R�R_@�ǡ�l3��c�j�?x�.��P�P���f��P��{�� A��[/�Դz�E�,>�4J�3>Nɦ\af)-$O%U�٢iG�t�S���4[�J����3��
0M�RJȓBLK�`���P�{���M؂z�AO^w�2 �$S�xn�����,OV�kzN|�'5�o�.a�)���d���=�闅�)q�b�h
ɽ
�����]�5���$V$��D�8�x$��r)g;��w�{�'�i�d9vĕ�J��P�5M�/���"$�yT���q?Ș�����U�y�]�j���<�N s�&s��d��X�^�E_���xG�8>G�/C�$w>��#+Ls͐�V8Os�B'�Un����ܷ1V9z��k~�����*����c����TJ�ĵSǏ`T�W��J�y}9�}�-��������
?����i��m��8�(��򲛺2f^�Ù�l�V��v��{�!�/[4ʋ�����E��S=6�����7�0N�$��yIv�6�����(��܍s�:�oU�eх1�R��#[+���6�O�p��!�ܩY=Bzj�p���w���I�38�w�{�}6#�����A_�_lUuZ[y�`�>�5T�=��J��o
��Ԫ�B�F]�hh��NQ�Ekkg�S�,�ڠ��͛h��*�t�FC;�4W���sm�~���������{��<�9�v�=��$r��������Hd��v;R��m�4E��,����-+^l�Pб��O�G>m�l Օ��ζ�UmZ"���YШ�����˚Ȧ�ǖ�L欆y
�f¯&�"�c0ǌ��8�'�m(�h�`UY�.Ԙ�����0G�/���휩]�Ϙ���̢7��CX����_6��?�����~YBK��}��|��jkFzDf���:�	iw�ozr���sP\��n��uq*s��CC��+��Y�I��<ҧZ]f��B
�� -.Ya�u}"��Z�A}���͹�Ũ�{B9i���&�#�I�l�<D�-:�V�.VPL�nJ���������6\?n۽u!O#s��ji$�+�D.�m��j���y=aޘm"S�T\����{�|�y���J��l#����?7+�&b���(A��nB�ȩ0�pK��&au�Kr��˗d�_�6>���"�;��s+�;���* O���tgdR?��B��9���D��6��;_g�o�ҽ/���e�O��Pm[HQUb�l���P�V�<`4�K$Z!�s�7�/>�<���ʌ��
�-mص���[.�%6X�jn�B���U-����47=!y5�0���*U|�k����uS�K^{�'�˘p��kV�����r
��	E���Wyysૻ3b����C^��W4{7�Ѭ _�kG��d�v[Zyis4��r��P�
�'3���8_�v6�����u�_���_{nK:q�9]ϋ��6/�*�yJ�ʓ�S.>3f|5>d��?ް���*�wN��1�mp�3�����E�3�3
7{=?x�QL�����͆cht*+m�U��ss���S�a��t/Z϶���H�t%;݆d+���!�s�w2 �(�MsX�(c�ƶ87��h;c����p�H��>�����$��~y��'p��s��
��[���z=k�\��
��
��|��51;�,�^u�����KCIǭo����%
�-%�5x=�}�Z�N�����^�N/�J�����yoŶ|�?�N%��IC��xڎ��{=�;b�vi��s��vH2�Y,-�M�( ����<�c<8���di�r��y:`�N�w�QšE�7�k�C
�
�yy����F��+�tJC>�W�0]��m"sZ}<5�鉍	�#X�g�I��[�0�:oQޢ����W�,_x�z����io5��ϋ��[�um7D�^�H8JB��_�i�hs1{�ܻ�.OV��<�#b�#ˉ��y��¯�FF����,���<f�8s?
�.�A��y��$�N#u|�2<u�r8G���0�Z�K��,I'\$f5��v���z=��c'�_�c̄�Hd�{�Sp����&,�0>�i&�$#M�{��!�úLjs8��Dj5�Gu+!7�qz�&|.rFt��.Dq��Lĩ��!����J��T�хb�Pz��x��ݸ��^����P����ݠ�}�K潞d/�6
�Y����8�����q�Ig͒6b�A��n�p�b�Q)P��	ݾh�ą�@�M�7�����#q���A1��f���1��u�+�%Y�{R�珊�~��8����ښ;^��f$
J1�I加���)|�*��ҁW�l���|9��I�18A�{��X7��/ ?\��^��q
�*�
�S&쳥���y��<��lk&�a�����Nʸ4�ͪ<%�	��v�r�>��f����f]�.�P��I;�%�m���z3`yPO�I'p�s|�	�o�����sL���V�OX������F�������*g��xl3��A�{2Sj� i�c�{�	-�_ѦR�[c� m�����w��Ї���3�Ț�0�@���$��((�Z�|N:�gL���.�(�:���7�	����Vl'����*X?�2X����/�� ��@'x��A�����@ߗ������|����z7��՗/6f�/�iʹ��n�i�)Ҕ}�mU�o��E�."X��؈� �iC�(q���6�[yZ�B�fa�Ù�'7�p%��(�W�P���C�y=���$�Ω��j�`[�>�-2��D�#/@�d��}�/�G]"�
�_4��7������I��,h���d�p}`�)9��@t!�w��N�4����JT.�|e����Te��؎6��=b1�tn&�r�r��mi�Xf���6���j;C���/˹�$����_�
��?[�ۜh#2�r��J�`�#B9�?��~�E�HC?>���"�o.�o�6� �DJ�	���=G��Wu���O/jԁ�*��8G��Gf��MC�p�Q�����*�/�ώ׎�k!���(1��n�#��8-M��'�fic;���C��Џ�S�	}q�?%���T�?E�
��?���9��R�G�jL>��%m�)���8bū2�1���YU(׆�E�<�^�����mp����Z��1���;��f;0���3f��?��`�`���&���3
Gh��TP��
qe�������R���:��'>|�zć`ks�����
�;o��X��kœ/����'�w���*�|EB\�oNv,4TQ^�f�V۰O�Cm��>�����P۰_d/��mXф��[��@�[y�Z�Pn9%�|%o6`íg+`eg-��b�%u����
Ԩօ�**̖��/V�[�[wT47DZq;X�Z�}�`VÜ\�3�ǲ��IeQ�^ϫ`����K��&���؋B~< 2���ȏ��4����c���pkxQd�(!�'��#U	b�sow?�\Eh����|�*����^�ƻ$�RN��jq��X\LL=߰�hIq�	Z��^��!�S��"�#�zE���Z�$|?�^�
���1|��A�I�ZN�F��+����b��}�w���s�-Z�8�?D⋳�"�|	����}Q��R�'��ū�i�{�꧇pA�G��#`fAR����U4��A�څq�g#N��-�濋�N��ነ�i��Y:ќp���N�k��s�?�T,�����k����}�p�����HH�E�E���!�#�b���s|EL�%=�+"ҁ�t�B��F��-�N�ivm�=꽁���ъ�*�{}�6��6�2�����A4 k �a�F�z�#$��K�ă���P�;'�sa
���� G"�߯u�>���Z�Mx�(sd��} ��}b�O0��6��wW����0�7C�FEN��bՃ�/&� �&��g��=Zv`V����0w1�6�Ļ���d�ئ��k���_dd��;���3�G�v�gL�&�k�ݧ��;�(�����`�ܿ�	�y�-��:��@+N`߅�o����Wrl��|���s��.� �.#y��]FRS8h�o��|���{����d,nd(�ّY"�\�zyQW=��,-B1���x�V�`�g��㝥�� ~h��B�'2�;?
kKk���7|�$�J�RLC�����(`�����+�4�|����&C8b2���!m�p��>����Y�l�c��5K�֕�2K\����Ta�Y��n��㟦/甔ڤZ=�8�rZ��'+ի-����"�M<���� �Qt�BmJ�y�ⓔ����ÚT;��9�w�L2���c��O
��"M�c��}2�A�b��3S��;���kW@�,X�|��k�S}+�3R����Bˊ��[���)��s<�q{�^���`�,�޿��� J�o�@^��ט����^𱐬������O���������ktG�7�C���=��4�W�����]f8�s�IY6���R��R�[��{���Ni|p�o�\�1ץE�!�R��Xj%�ޔ�2Bj�� �IW���ʖ��%R ����o_�(�	o��OY�<��<
<c�k|����i�Z���:�1�)�L
uFfG�!Ϣ(eøz�={�N��J�D�pڠ��0��#H@��He#�F�e�.����v\�Y�B�b�iHe�Ď��d�v^�-˲�Nlg�id������G��5-�\ɪ����{��bg��$������Qٖ� �lҨ�Z�p(��,��j��ҽh%Gӣ�`G���A襔�W��;��O�#nE�!�_���0K�D��Vla� ���,���#��uX�}v
����f�I�ϗ(�FyV�9���x�N~�RqzӾ����ub4�g�w����ɍ�ف9!f�yWa���ŕ���͛닚oZ��Z��	[z�ài��^WS�w]���S�����8�^��Jm_�Y�1��uP/�!��
��c_�	%d�#7����{�t���t�9�8f(�Jp� 9}K�v�I��n.?��C�j��"�Q�8��Q���fXM�:��9�N��c0�����@��Z��ƞ�N�z��B�+��Ļo��\�{;x$wy�`�/#�#fG m�M@/}[H�O#��Z�@3�Nu>��>��o�|��8�i����]
�\�=߼H�بTEZ��e^JO�;�&���2���f�j5,A��Ds�f٘ ۮ���-��#��?R���K𶽖]۾������bi1JȳG�얐S��$����38DIA��;$�����َ��^����c�݌'�:�TR(�D�Ķ�Ȱ�٢����^�}��j�l�jo4���Bݛ��P�W��5�:���tŎ���A&��N$�mT���U���ş����}c��5��9d�s躿9�@Md�<�S�����s�x.|�,��*�Ζ<�%M�?R�����/�p�\��m��@�x��<�La0;|Sh^�,�eO4��k�Z�0�ۣ6Mɤ� b��%1��PA��-��T�|>�+
J�����8�I�=�x�x�-�!Oe�ErDB��f��G*�����T�G��M�V�`F�ʪ�[�c��zH�"�T<i�ѡȑhν�}2r�va��(�l!MR��Ɏ�;H�ƌ��R���.Ӊ2����Ȳ�l�h����]G��]x�0�Y��Q�ȱ���It��B��Evpi��'15e^τ^�����kA����{Ҵ�5'm��u.���eHz�HG�1qv�Y��J$l��t��B��C�o��q�+`����z���,0bR
�'����ww z���(�)�/�FZ'�.H�z��ktdK��R����D3��)	fqL�:ev�Y���A.�� ���6��D�.�[X� mx����O��u���c�i@����8�y�7�@2��DCp�.A����T�I�J)ܤ9��������9r3	+����Q�q�ҾV�2A����b��/��QOTϒ�=�T���W��l��h���p��D
qK;w�2�'Y�+�e6%O,U�dDı1�ZK����SBm����K��h6��i���駉�q<���
iv�?O^Y�.\b�[i��0g)��Z��V)��j,�S�N2޷A�v_z��(����D���(��8Ƶ�fQ�5��
{��a[C��=�
��s�hVh#]�/Q��A���(�c��BHӈ�2�3�����D��6�7��G�����0���O'B<e㉨�Y���?��)e��)��'�L��f|��ᛌG ĴR�l�p6�qH���z�^y-������p���+b!/����x
Ex����?�������ݾ�?�+�g���U�z2�ޫ�������J���^+���͎l�W#�C��ݙ�Z��j�N�B��g�0�4�ʁ�Q��2���&��V##�.�e��+�����nc��1�d���u��goM�kb,�Ǻ��9c�Mj���x��@�t���P��0����F����8�9�1]tk�����f����U4�w�m��\�߇����e^,��{D����֣�fG�Z��ܵ#��b>c�=��?���(qK�V�8'y�"��S	}1�b«8�����$�"�L�^Qỷ�"M5��.�F׉��JFܮ�P�`��A5���A-�qj���[���ˊOwX�ȋ�6Q��"Yf�WDV����E�����Ve�8�$`݌��[򼞗�D2�x��7ߢ1�{��J����(�ud2
Վ�����uf���2����Q����M��&ן�H���	|On�J���¬4�|�D�2�P�W�ZH��^d9kQ���Ro�՚OXFɚ��k�+���bT�#�xx~��H���	<�k��En}�\Sn����G��d�M�2���(OF"G0+��M�G;-�y�'�������=�Y�Ä�����o��Cc�����؈1����o��%�bȺ�+�rZQ4����ap//�W6�1W[�D\n�����΢��:h}f��+a��
� �9�
3< $�$s�0��)N4v��r���G��.:ʁ�����]��DU8X�&TKu�(7��+������B�)�)�i�<��i�pW"�3Is.q��H�߳��D-��X��r���͈y��ֆ����m�	w��3=�m�(�\��ݲ.%4��ڜ�T������Q��7#��Z��s��A�K�����YAL|��BS�;dn�@9�W�߀�:a5yY��jt�Ν�ά��N��N'�;	~iVϐ��Ò�l��daG\��} ]�S�³�O}(���w�h,�
���;�]��Q����
��~��l�q��{�)�NZُ��=�k��J��3�H��}}i���,<ZJE�D�P%���h����L�@��W߃�v܂L,�|�]�Su���g��)d��w�c�6�8���߶
�~sh��WD
x�qŗ��ޕb)�`����F�%qw��t#�h\�e<�³��?��o����l�-K�b�XN�gg!���iNf���z�Oޘ��M�Qm�ഺ]�%7�K��q���j�G1�%.y�omt
���w�<ه{&�^��������^��s�7�b�>���9B����4���9�B��Y��tΏ��d�u�Ο3��.M��@����E\L�&����k�7O��Y/RM3�8Чc��'�V�q_��к��i�=~Z�1�%�}/p
(��{���bJ`u"ț��׽�o܋���Pa����7XH�Yĸ?>����g3.Z����3��6m�Ϝ=��^��=�����/ϤR��;�[����3oK���!������~ *��\�#�"���c���g|� ڷ����m� ��m�'8d�o��-c��w�{�}�54ҬO���� +�������h�����J������Ks�����4��z�na��{��8[��%��X�A��pN�jZ�
�-��oV��ſ����G����d�P�����ל&��iq�F��ݫ�r��0��`]��r!e����t����sL�s����<F�𩜴�6ו4�`{_��� =���!�����۽��.�������P�qR�x���'��'�Y:z'R��n��T�Tb��kBD�.;Y������4y�]�V�����>�Y�#��A�y��S�����������ܭWԣ�s1Q��5�qC�"��-��ͳ�o�?g�?��گ�BN���<@/5�
�㾲ĂYC_�?K��c���qJW��SV���[�|h{��u��{н����N<��ϸw��M�̪S[u���&��9>��b��z_�z�Ap�I�a�A~ZN	���5��؋T��xܹ�E������_��6\��k ��;H��}��n����B����G�
�{�Y��'��Ar� �Ž�(�{;�0�7F\Ž��zeﰫ�{=܉����r�B���OݚJݚ3K�eK�A\]�]	��k�Z��V�y0�w��lj��s�J>�5UKVSn������Ѽh^Ї�^
�a�v�W������.ץ#�+QQ�/��b���K�h���hh�.s�m_�\Z(Ց#m�tD��v���jr�\����lf�D��U�KB�������Ͷ_�	�ܭ�~i�g�����m�#�p+�u���9���ne9�Rm���� L�<��	\�Sz�m� ��|��y"��e����/A-$���u�@�����İ]��op�b���>���;/��P|�db�{���k}y�w�S�o_�A���\���&�_|�ϸ�p�s�.�L>�1�:<GT�u	Bh�KЃlD,X�u��u:�ʒ�#��
�zZz�8A��(Y��K	 s\��%�>��&����	�5�x������B�8I�_nY�>hS��/�p{h���s�kǽ꾲�ldfv)z�?��s,S��_6�����ze�#�؀,��D�A��O��؄��߼�c�Ի>y�q��Չ�����4�e>�U)�#9u�'�i�>��-g�J3����v.���Y�A����ݰ�x���dv�>��u&m�w�A����7��ĀV�թ:��E=��-��!�=!h��9�sR�3.\	�7�W���>ٟ���~lS��!��w�^�ݵs�G�{�UN��i	;�]z�����r��4�DF���B��Q�W�{Y��%H�<>���>ל���0K$�"�P�i�u���9��.Q��Z�"�FY��b��T��򗖸
�����,��m�����:Ek���"�RE��*	�OOL��jNs(7�E����q�'mZ]^[:*�S�9��T�6O���,��M7A_t3�C.�]�=�.Q�%<ݍ�+��]��G�p3�@�E$@~O�5�#��9|n�wOʐ\���F���Z�F���Q�o�Q�Y�e.
�-�3nFA@���b�!*�W#߰�����ZM����"-�
��?�L�A�-�|Lݑᢀ���
)�7�ťcX�)����n�����Z
6�H#f<���n�3:�vw�E6<ߴ5�UB��.*h����,s-X*�kQVz�`5��nY��V����S��\_zzgG�S���m��t��H[繨	sz'���z+����d$�v�ЀC@�q�|��˴ju�΃PG��/"�5�,e
\�ζ��:�'1鮅ss]3Z�o���6�=w���z�c�Ȗ��>�_�NA/,Z�u��#�k[J��~զ��p9�
��p+�M�m�+]�gO/��1�p�X7�N���T\a�-I;���P;n+�ÜO�j�ڦ�/ຐ*&�N��2�'��6
���f�BC����5�W���� ׅFBu:�����K� E��%Q���G�Q"�9^�Cԛ�~���
TYߏ��j]
�{_��_����W�B�80ܖ�e�6���r]g)�k��\�п��f;�� {�	��y߉��&�sW�g�~�Hc�
lSI���HR	+��Ⱥ�R�dm���]�Vx�r?.A�K�'N��:��
�>Ļ�nd�幼i?�sxw�$�o?���=m�V2�
z>�������ږ����:����8�P��
�qiDv(�J�k�?߇�����Z��B�W�}K�\���u5�9�9E
+��Gݖ���U�J�K�{�^�Ι9>��H�hV�Bt��DA���]���n���MA"�z޶"h1O�?i�i��>�\
T����H!�5:a^(<F,��U16L)m�5�V)[4��EE[�l�wϥ!�~��q�uӭ���X&�	���րq��H1�c�vZ� 
���57�@71^|��7�AkJw]xr	����K�ބ-��S�4�Z�H�YX# R�˔L=c=��RZי9E�0w1?���^	qG]�"a&θ�.�;xx��\���|W�?
<�P?��j�!�ޱaM��|B��B�8���_v*��
<��#G��1��q��+eqT�f���V��-e7���t��]��������FEbNg��.-3	�{��]��z�2�x�n�u	ҹ�߈;t��%�xd����Z�ͥ�<ֶSH����;�fRv
{�(�at��ޛ0���ww���<#%)??���U���xT���U�+zW��Ή�i����H�q���gv8וt.}_)���2'�U�仴���k�k>x2����
����/si�Dv��*��'};�?I�<�����_
�_����L޹����H_nЅ\n?u�-d��JH�Jʟ�H!�<AEv�O���Iׄ�H�(���+Rqӎ���M��� n�� �*N����J����+�c��[:��F�P�(��p�M.-l�}rm;u������݁z�tӇ�݂�?�/\�|�jn݂bQbs{�e�p�%δo�-���U�a�?+X+ʃ�X�V=����(���n'�C�z�uc�7$V2�Nv�$�t{�[8Q�	���,%��3x#�~��$ꦸ�`��^��^ʊ���I�m������� ��!5�ء�_B�HGSa�>�{�T4�XW9���j!�ݡ#/��P��,HM�n8C�����[�][�Q�T{IT�bT��B��n΍���Rt�@mf&P��N�n�d����#K:kJ�v�R��&{0�H�%CrI�G5�<�%��Leu.Bw�yUﻢ���_?r޴G�{�`et�ܣ�dw^��+�9u�cZ�Ҏ,�D�늘5��C'�"oc^H�ޔ��w�/��&�c�FB��:\�M����v'k�j��xP��K�qk��%տ�<sv���< 	�3I��6@���:�}�-�N��b�������й(}m��K�I/��)(�Gʄ����)+��Z�˺CR��d��a����A����6�x�u����K���
sg�z-�@ʺ,��цۑ��$2K�;
4��u�w�׵��Jd�E5Z�B]�}�w+�%��p(h
2��Q�ֶ�Mdu��"�KֳSˀf�V��͋�ÿ�S�D�
kE:HkΊ�+n�.E��
��ίȘ"�ś��m
ܲC�zZ2��|��Ө��hF�a��z�TV�LeÝr�1�Qm���<�+�C 7�
~0�m��!��J���a�<�^d�-��z(h���WJl�K�-��ճ���c�?0���p��'�E��DNoAR��G�H��f����K��7��xo�
I���>�Η�0�ˬ�(JmXd~��X��I��4=jB\j�4���xY�gݥK(V�f�T�/o�ka~+�I7��M���=�
�d�49�s%m����u"�7}}�%���ۢ�G%v��L���j��)�4pC�+�3�_FȎ
J@��(�,�8�+�_��I�pSK?�nW�_l�v�<�v�Xl�0g�H��[�bӋ��L����T�</i!ub{G)���)ܴ����o��;�-J��?\zY��������[����?.�38B��G��t����W(O���g�f�}�+�R ��6x��|�s1��L�3N�a��;?_?��5-���u��1�Y��9�2B��A%'�+�����A_��MF%������y��P�����t�, |}���e��$O�,y"��kع,�q����3-,Q�8��|W��>��ٌ+<��7|߈�.
���4�
k�ihv��O���>n#)�%(���������0W$�g�a9p��i%��ow��YiЗg�3#A�)���
���K'�@�_��u�\#H�׍r:qѥ�D����r/!� I����Ꮧ���l��ރ�SG��5W�<�K���oMA����TI�+D��q��ѼrShz{�4
K�j�9�N���!� �D�u�9X�@��Y����4Jr�?��6uy�{���6��ڌ�m��ɧn�~��5�;sxO'f�Y5��I>+�)~n�)���+�W���Ǡ�H���+B�T��ſ7-��*uz�yg��OQ�!<�:������VU��=T�׵9.E@��6�T.�q}B[qZ�i�A���&��$W���������ӣ�*�Ν�J��G72��z�z��+n)�.�Q"��Z&~���N܍�P�7�e@l\�\�TYQX��[�D��8��eA��D�Z�)(���F���O�M�!R��OxT�є�+�
u��H'V�+���X-��	K$���&�JVE���k�nl}�r3�"�t�s#�{�<K������¨��5��T1Y��u��*�'1����w1�[���ݟm=�ʄ���Kf
9R���gC��K�j�������m�ᔊ/�(�������}�S[qY4�
�Vj�i���u�.�[-л���\��ye7���� �`�l0�Z�u�9�͒#�P�/�:��-�aklx~D����"�KuR��#���u
%�tV�è�^�zJ���9!e񧞺�b�V�a#~Fӂv��a���u���A�u7X�u7G�p��I-�܉�͡��n�hn�]���P?r]V�>h(n�{�qG���Z��g���-�+���{�:�ݢ�c�wmx"���;A��4�弪܇5�3�ոh�nn��̢���ڭs�K�\��|[���}�Qtǭ4��뺺�K>�����{0�)�}�T+�s��W�=�^4�l鷖��^�u���()h�����(�pͿ_U�bʺg3�	��\�X�-�=غ`�(ۘ�JR��5e��.�L�"5=��
Ϧ���}�
G,��K�j��"Rz�m��L:1�6x�AuYV����V�;I����ԡu�6a��6=�)�nĶ%�w��V��ڎWK�`��6Is�vH'b���^z�
=� jo���[��]آ��Y �[�f�U.�}�g�K�.��_�˱B����r�/�� �w%K��$7�T���.x��Һ��]
���X�,�G�'�پ|�F�޻R�>�����}ǖ*�֩�t�r������X/�8
���`��T�fz"ߕNT9�i�h��Yr-��/YD��
�c�EC��CW�)�
�{���}5�DrĮ0���/��8�g}��u[��w�y>���/�b��fl���}�$}e��M�Dl���R����{�Un��T�섑����(��{P�:r�N�>u]�o����qu�}(9lϊ��N`��U�>�þ�cj7_�~�|p��÷vsζ@��B�ަ'd�Ik��"��)�_An
u��[ix�j���O�:�����c�=FC��L�={��m�|l�z4�LVR��\GT��.���Y��.ѶV^q�.�����,���]!�-j+I۞?U߶��.�FL_�7-���w�c�7�	������tb��aV�:��Z���P�5���no�+���Q�Nik�_���d�B�����{\��;�K�����ଞ��2E�,ΉKW6�7��ײ����3�Ե`��d��1ќa���N|��Z$�� I�b	��$;U8���h���E/Z��;�F�0�>�Y��i��c����h'�v�3�n va���h
R{<�{}�)�x�����z�l<��x��{we��Ol/ޗ��Yug
+�������A�)��6��������%,~B��c��}iN��4:�ۤ"b�xr�.Cq�=�Cs��2qݐW&�h��+�u���Q�GVzF����(�n�j�8�JT��;����T
��-�W�xY+�J��z"�ids�t���JE
��kf��
	;�Mg��+=M /BĄ?g��
�W��_Œ{���! ����*���tV^IpaX�:d�0�I��"�^��e0�I0�	�Y%R"�|�I��ؙ�A�&�7�(�O{{��;��� ;�&���L�$��A�:��w$��9wM�_Z�N�t�F��3�k�VÙt����_S�&�����6�j�խ<�W�7���3�\e��O��(y��^�l���E0�	B�saV�8-w�l+��U�6H��9B���WfD����: � ν�+a�	�l&�����l���;�3T�OR��=c.I�n�\��ū*��Z$�b��$��]���K�$4��F5�B\U9%ء�2�=�:�)`/~GfrJ@����D<qxc�!�彲,a.q���u�,�h.''�.ȃv�-.a�r���H����A��|��s<�j;攢��c����ƿ]���Y�T��R^>�N���U2�3o�z%��,|GR��͐C��T�es�".�Ŀ8���^���/Ks��^�)�x��˛Jj�`�/}��>�ul;�-]�ߩ��ǳ�{�R��;쾷!)	�,�����˨���I`A����eZ(���ٯ纑j<���#�7�&��..�ԝc����uY�b��s����ztV��%����i����^l����|���~�	��Ǵ��0�H���9/�r�� &pn��{�����J�(;���(-=
R9��
1ج�Cf�и���w�5�Z"�H��W<p-v/9���w0^���FV$Xă����j��'_�*��&&H����D �9%ղ����T����ۮb�m�sW��.����O�>��Iz�,���`
�� �>��3�d?X�d�3����%���;��xԈ[��!L������wV+��;��#xY�F�PDL���Y����ēf<�7�RElM�.$v+���3�Wx��
q�z$,u
A���(�hV��K����Ak[02�U�C���iGO��8�}Im娠p�v{S�S�۩�������Cl�h�&t�:��N��:8��eGL�ɢY�.b4Ų.1ig�i�p�\$�YfRn��d��SI��-_9�X��a�ZϬ*~�!�~�,��Y��*���;c*:��a��y��|����S�����u#��]�$N�~w���MW���Ϯ�6��UHj��*��>���h[��0�k&��&*�n"����� n�mT��t�ՠP��W��- ]��d_K�^ �I�����"�u����L�OTy=��

Xgz=�^Be�#����׶��畕[���P��X��������N��Y�&��_ӝ�㽞a^���^��D��|*~��3�[��0��m�,,���n�*Zr�K^j�^=�.��i�b���T|U@�w�!v��*횬�)��n��P[��������应Y�P���\`����k�;�nT;V1��~�{dRȺI4�k{W�!����:�p>��4纆goi�u˳�t��\W��j�i�>���i��-�����8y�"��-7-���p>#����e'j��Qy���!Ea�+�@6���2�vjJ����W����oՋ��$���,^?z=��H�:s��|%H�r<�f��u�}o�Q���75���p�ٯ����2�w����O��L�Z�i۟���VN�����)�y�v|���
�j�Ea����@8�u���m�\�����cۭ����k��7�)Y�����{�e{~�k0/����d�ol�����/��W�R6!lb3����S���2)�g�
�Y���c�����UuV���!�.��MkZ���oz�� �:�-����5��C�x��LCX�!S��3������`�N|ωk;�M�5�����]ˎn��~{�B
4���w�a�\�;���zt�Y����LGIZ[�yT��VUfxn��!��\���ET�x���,YC��_m�6sg2�D�'��#������ٴ21�&��8��G�`�Q3_�|�WĐ�t.1	�c�y�x��+���#��6�[���7`lMN�3���"��|����@͚���t����؄��q� �RD@�w-�:*�2�MA�b�MgM"+���Cn%����M'���y��n)�-�S���S^z1��n�����G��c����lb	�K�y�鋠�%���j%��3�M2L9Q�Rl�Y���K��4=�X� �@= ���t?؟�&� Eq�Ma;��Ȏ`�Y�;g8f��4�r�MӱE�i�7�ՆJ��"
��In�4�7K����M�J��;��;t�_��=��.��y����PC\=հS���<�5 w:�;l�0�5?b�e�1��T��y��%֜����[��t͉0e����}�ic�7A�%�wZxr�����2�F��,o��6ؔg~��k:h�2�9��Ĝ�L+�z��,Ѵ[Js�Y�y#iZ��� �p�G��Q�xԟ�Ң�Mx|�,��H=x�U`�zv�3Ʊ��'̨h'wgxo��0��O��y���K���Ŕʌ)���I�����)����5���{�d�����F9���~g>kJ�a����l'��,��PÝ�1`i7�x���a<�u�ƉsG�C��k�1��x��;�,LnS]�T�SU����WH�����H�뾚�oqMe��&i��r7C}Ƈ3���>㣙��i�Ng�'!_���W���'�wb?����⼷������jָ|#��'�'�C�<�8�.|I�c�t�I����7��T�
������A��'�%�e���h�X�	
�q���?ݕU�p�Z����*p�JB;d��@<�|���I��>q�(��l��.@���f�JR�P ��F��"��Q�$B�?�.ڨ��gh�(E�y M&��p�a�üm�?���q�e@Z%��\��?NӘ��	����߄����{�:87U���z8+]��K���c>(\��� �@�F�B��%w}��}�s�
��(��� �cĒ���)P���-M���d�I�#f�1�3������~jS�<������
?��!��~H�C������?,��R?��a�6��?l�Ë~��}~x����N��#?|ᇯ�p�W��:���z�~�C�b���4?L���9~X���~���*?l��3~����������=?���G~��_�����{?t���t�~�C�b���4?L���9~X���~���*?l��3~����������=?���G~��_�����{?t���xY�O�I�o����{��gC~q-��Ǫ��:쿴D.Ԇ�G?���ܨ��B�T�:P'����
�<��
�UkW�|j���s����w
֭F)���	�����
�4 �$I�2_�!	$�E�RKPK�E�bDHDJ��2�@��9E���>��+ZU�d�v6�q�l⽱t֠��p�S��XN���X�#&!���O� i�R�7�	���w�z����D��%��@�E��hXS?��p���u1�z��p�^o$����t�{^�ʹ?��G&&O����Q��U�R����m���۶�x�߿\�sW��=��Z���v_ݸ��L���2y�bH`н�ޭ?�xO_#�H�T��{^�s/@���z��YP>�Wޚ� �����I�5}��Aܛ&`2�I��'Mє��xp���������W_L��IKH����}m�������7-��M�ށ�|�M�M�/x_:�i��A���4A���A��߽vvo��/-�O����%�i)uoZFߋO~���Ҋ��C�Kޗ��>h�p���08MB���0����'-���O<�?a������e������K+�K�/x_��p��b��<�#'�@!�H1.��j���`(��!W�/с�,����@�8��
W�?1%%mB��)ƦN�<~��	�)L��4uʤ�'L�8v�d��	�&ɡ銟N��SR忪��C�������O��V�I4���'mR����
���w���7����G�����|�1���d@.�?e.\U�lX��`��V���u���"FeX�lZ��y�p��ٰ�Ć�`.`�~��`�jfe���k���3��[�T޺���:f�Sk�u��WΌ��̚1*f�����L�5L�/�?K��h3�Y�����I�ƌ�_FX��h�Z�dÆM���&����NN��������k֎�Q1Ә�@��i��h�����pàl!k�y-��#\3a�֬�`��`=�v�T����V������%��S�?���=�?����&�NҤ����O����7���)Sa�SƦ�LJ����L�.>�]�����������*h����
�_����W�/��$�k�[��\��`ņ��
f�6�Y�f�S*��_�o\����I^=��oO��lb���Vy��'�����[��w�V����E+g�����ِ<�
VCU�ʫ���4�l}A�/��2k�&f6��d�d���O"p�����[�
'���gq��Y�o�_�|YQފ� ������
P�_j�(���x��Df:��3f`��[�iƦ�JM|�k����������t�7%U��2qB*�i��R]��w|R���  �LJ?~�fʄ���_��_������_]������W�S'M������S��Ò��a�Ѓ�3�`_Z�ϷL��F�&�!�=
�Db���ܭw�����(���.�����ht�t����ؤ�����D���wJ�=n'�����;�?���0o%�ҋf�{<I�ێ��3�ۙg�{�{��ä�0ُ�������n�������������k����7�����*tﱿ���N�_���������-��c���[U�|bڸU�ɫ
�l,N.�<1yb���kǦХ��Ԭ��yk����J�y�?���{��'�nH�,j�jхo�Џ����׋���y� yB�T����^����4�?[��	����_�W�B~�/�?���~!��_���_����Y�����~!�/���S��
��}��n���HXD�e��C�X�l�y���
W!�Z�ch�
p�y6�C�kWlX�/� ��UכQކ��ЊUk���Ek �q�e�V�-�5iު����]�N`��:�p
��	S!��7
�q$�'2�#h�O�Y��*ԟp��en�2O�{f�i��$>ɴ�m[��^�c]��1}�{��|c������i�k�;f<���y�7�a�>��4�(����ͧ��,�v;D�=C���!����7^;Ds��D!$*=�� �ߔ��ٷ�3w�q�B�����o}H
ɿ"�'��6Q  �!�w9��(�nz}�(:nDҸ��$�)�IB�bh:��
\���AY>��?V���hC�����s����6>ut��Ѫ~lჰ=>�h����~l"a�/��%�7�g���v�آ�z~�x�.���&��o��2�v��?'>��>�۞��ܶ�+��xN��s��#����$hQy�+��,ow���F��9h��P��D�d��?����W�l���u��6����?;<P�7���t�XG�A�ZP�	}2��v�V��S�oL������9�6ߠ��}�h��})�ے.?�>���E��9/�X2���dm�{�¬m���o�Y��Rrd��Ӌ}�ox�7�t/�a���~{���=gۿ
�0|Ë���%���2�Wz�-�b������I��b��k���ln�Ё�zj8������:d����RQx2�'�S���0�a���;���7�:�o����0���0���0~Sо����� �b�H<��1e�l�D�=��F�
f�G��R8��S�0I+�aVTj��M�Za�l�&Ka��n�ƌ����i�<��_��Lw��ڎof��Zvť�p�5	Z�Y������ı=~a�`�*�bdKk6M�����3]�r��E��s�j��JՇ\�ڀ��%xf��R�Kְ��Úg֬`׬�������!~Ӥ
�ƣ�7�t|X���ځs����#6��oA�a+����
Q����6ͩ�tL�/�s�k�W��y?��"�x����A����'��� L4��R|�^na�U�~%�w���Q|W��{�w)�O*�S��/����sFt�=�:M*�"��џ(��BY��Xـq��dȶ�F�]��6���_�O��¯��AM�7�����_����6�_W�����3:��o)���Z�[���;�����٦���_gϮK����=[����YS�z��wߤɿ�1�]eJYO<������O)�^���Dx�Oq�`|	˯�'��	�+m�ߐ��Or��E-�f\@��{|ƿ���q/�������5�F,2��/����wOu��Ҭa�QN�Z������A\gN���/7����sV��4އ�����#g���n)��FF�f������~���u��-�����
.�>�Ĵ�}��Ri��� $[��'��쮑j�oD�R6�������dϴKL��왏�L�h�����Phr��<����A�ՊU����o�Zd�9[��_t�&��h��� �*��'�Rѱ}ׁ�D����z�!'�-Uh�3UO1��E���S�ݔ"ZCn�*�P�^��Ӭ�Y�W�oT��Xv�Z�j?k�N��@���؂����MuS�!r�5o�_[1f����r���͌lQ�)W�i1j�f��P����#h#�8�.�V�BUOk�¦���C�-�'�4�~3���n�C|i��>�X%B�U� ����5۳�lZ�^�q}R5ϙU���yo�'W�?6x��1m����k��jU��5�5��� �].��i֊>��!җ��4V��Bt?�O�	��3�� 99�0~b��Kҏ�0��^?	N�i&Z鏈$��Ab4_�E;8�H3I�F�2��?��|?8��3�O��_sm�;H�ʦ`��*�p1|i<#�_N!X�ge��t!�w!��V��b�X�����d���$9ϓ�ٹ���0����$䌱�#��csӳ�f֓'9�� j�5.�B�u�j�&�^ ���&дh-��.���m�(�v�=���C�W+M�+ת� �a'���#n�59lEЉ7i?(c���H?�g@�����ϲ�g�
s�3ǎ����k��(�+㣥�yrbc�4�QUs�@�Otw�?�dv6[(��E�"�*�l���C�b1�T�yq{�a�z?"��7�m2��Pch5^�*]תT*��R��U�!3���tP�J���F��lj�J���7mx:HS^��|� ���̦�\��Z&�MV,�hz
����Gǃ��E�?��C�<�{|�@�ܥ� �O���o=�*���w
�kaT�]���X�h�kL�pFn�xFn�t��5ܮ�UK�k���sf �L�b�����]���OZ����&�kP�5n�9�GD�]�-�]3¿�/�:M{�5_�q�kR��Z�r���~	�kL+�MeC�k-ǟ_v�#��`�ݹ:�"��Q�e����:?g�Ώ��6�_��Q~>t��;1n��4x��/������U[�u��tj�o���4x�o6�5��7�+�H>bD����6����࿉��6�u�_��
.�czO�g����(��zؕh�w���j�g����~��W%�6	A�o���5�����'�?��7J��$���1-��d��L2,_�E�'-�x2�\�4�~Z��J��v�eM�oh��@#�mE�~��o�ݩ�r