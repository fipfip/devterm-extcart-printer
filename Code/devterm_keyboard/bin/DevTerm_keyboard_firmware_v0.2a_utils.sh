#!/bin/sh
# This script was generated using Makeself 2.4.3
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="3133134892"
MD5="d205c6f165bf9fcdbedb5192cfa13caa"
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
targetdir="stm32duino_bootloader_upload"
filesizes="104352"
totalsize="104352"
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
	echo Date of packaging: Wed Dec 22 13:47:32 CST 2021
	echo Built with Makeself version 2.4.3
	echo Build command was: "/usr/local/bin/makeself.sh \\
    \"stm32duino_bootloader_upload\" \\
    \"DevTerm_keyboard_firmware_v0.2a_utils.sh\" \\
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
	echo archdirname=\"stm32duino_bootloader_upload\"
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
� ���a�]�w�Ƴ�W��
�:��mɯ�!��@K����{Na-�mY2Z)���o�3�+����i�s K������gfGK�V�I�)�HpOĲj7�͖�Y�;���������������n6�_����
��t����`����:t�X�2J�G�O�xҏ�ON��Q�vX�(��@�"O�]��(�x�7}H���X�ӱ�!�b�1�J3����	ݤq o��s�R
���B?�D��t�F�%k����PoX��6i�D�SE��H���7��/����n����n����t���[M��~����N�f�����B�¶� ��>e�������7�����z�|$<6���Lx~�/~V��
K"�5མ�T-��F��0��ʋP ��ɘ�FrP�|4�W���Q�};���ީ7/��M���[���n�[7N��C�/�����v�E�o4��ߕ\����]�C�q���xO��P"���h�ݡpߒ�o}� �~6Rrp��V��7��"��q4bZ�����U���0�a���B��~2daZ�8b0/I*�'"f����9�G�c��7�������D"�2��3�VٴG_bA�쁢���ZD죉�B!�B�"le���AL���y2��Qe�^�ZR$��P}����o��k�c)�eaI�<dJUYlh�4!f�gf9o�d?�������'���yft�%���]����/���v������ŵR�ʾ��������V���7����d{`Q���&�D��
�ʤG�`<�#&��ΨO��xBɐ'l���x�z_���K�2xZ�1|-�0U8�
���� �����N�}�Ϟ��PxV��[����
1�g�"�G<\�4,����]��|C��e#�km^��ulu���u(����_gQ��F��ߪ�_*cc��J��I��6�>�q�B����{���X�ζ�x�1�� ��E	��e�}�T��?�eW[W�q�� ����'�M��$���< &����=*�Yt0�-6gY6˚�� Ē`��uj�3\��<��p��� �ʂA��<!GLz,J�q��F�*
2{��M��s
��j�l����z���<��
 XmOrX�"(��1LD�%lA�H�l<Q��c��'//�Bߥ"��*o��h���<�1L��+�Y6��W��ф��5�7X������~�_��ܝPs��Pd3e ��&��� ,��!<Mf���B���i/����ߡ�c��(6F�V������"I�&��p ����
��1;�V^g���3&�	 ��3_�2�2(�L�E��FS��U��2��_���G���\��U�X�3��e��1��1
¶��������DV�f����+ĺ��0�����t���d��[[�>_�/���Q��V�m,ޥ>��]P	w��jR�<�'�
�f<
��҃���G?p
]�,"��mE��8
%���A��k��n&|�g(
u�/���]FT_��3�V+�X�N&&�|�� ���"��������	F�"h-�B���
+	 �	�Wa<��118�Ԁ7v����^���f׬�i��*�sF���[��Qzϯ3R��1��؝��A��0�]T�N/]�K�^E���	������ U\�i�o�a���+�����j���Z��_��/��;�֢������k�Wo2��};�0N�.�����/�����l4jFqS����G�1tc�a?*����XXӬ�"����������kP�+��v�~.�����ߏ����'�7�0����n/˃J�
�S�2���j�32��yf�\&w��l&����2�����,��_�����Re_��7�f�\�w�U���f�?�Fy�<��
��Ε[�ޟ	�U:�  @qUEt��J�#)�8�	f\1�T̞PY;�$���Ɛ�	��J�)��$���@)`�L�"����,!��R���;F�1A�/Z�{&ǘ��9&�4�^���#���<�H�!��9���gj"GM�
���<�(�ZE���cl
e:����E�6(�!7��%(bϣ &U2�^�,��K��
Y]ǹ���/hT<�2�Z�_N��2�����-�I�r�w�|�>��;$��� z)]�Rw���،^����-dM��A�"��v:�a�H�i+Yn(�'R�~$����Y;(�9U��diFU~�9��}>��U`���sҾ ^!��l����+���_��W��6��[���?��#iZ����o��ɸ4�����;8����]�����s��L_:�{iٯ�]���S�E�AW���	S����ת���*����i՛��o��������l?[0�N�7ff���#����<ne��Q=�ǳ&x�?�*�Kʼ�b 
V�o,G� �T�l3�bOf0������wU}��U�H/
1�Xv���g�?]VEk��"?"�շ[�eG��~��	S���w)�P�C�9+~���.�KM	����$��g|�
~����^R�%���*
��n��x\ue��e���9F�ǳ��P|}�
E9��
�_\���_��K��n6���Q���
��#�#m�(�$��Cz:�O�oC
B��zl
�`Bc��{�jw֍������}����Ai!��N�:D��d���3s7/(P
�'�2)��(��f'D�Q�>�)v1.E�=r���v��sXv -�y��U���7�\X�ù�L-"SzU%�苉��&�<�'Ȭj>=�.	�ʅ����X���֥���Kdc�c	fzC�G�Q��NaG٠c������c�c{�99/^g�S��U�������Lu�����S���C�~9�r�i����{���}C�빙�$H;\M]���cd%9��٤��4a���=2t��M���9�������G��?�<�D
k�<��B'i����Ʌ6�l��j�t�Z.;4��v^���O谕h��<C����.���`<�^�ϟ��o%��a!�>83Ε6Yց�J������t�3gI2ϯ7��Rw�=8�;�Ãf������<���xz ��L�d'�������u�ts)S�i������j��[d)���Ѕ$;�E�����,�MrS"iR�PJDDP����cG��!��,�����"�&��P�?sι���
�1USNJQ�s�tR,
����������׍�j�XU��i]bC�Qx^ �mF�	�πn'�ωRtA�������nH�jb/@xe[܂�#�A/��8��hL�����"�D��edm���e�cx%P�*��_(��Z'�m�/�:t�s��4P�Y����G�Щ�:M�?|����z�so�^��/�< �[�����P��x;H�)� \N[�Y�
�#拤`o).�Nk�£��I0�O@����FH�hd(�E�<@�zyI
��4{y�5�]�)�*!<j�9]n�b��J�4��D'zx6(���p�����dg#?{h�܌�Y�=c�WCs�IC_(EC��(zƪD"����ND[��#�ܤ8K|A�xYU�4I&C�bb����\8�n2|���.x��0�i�J�_$	�.�B����\Z��`�*���<�3j�I� 13r�nP�Kyma�h�	�pX��t�~ץh�4�"D�n'�Tq"��V������|a� ��a|Bd|�-&�S��
h�`u&�N��-.��5ܳUe��F6���5�<d����ЫN���/�P�_'��.t��e�m�@fg�v��f��4

�N���k��R��+4r�L�Q+�
��P}�o��!�z��������h��_%ׅ���v�i�>�k�7x¥�Q37�{��:R����_�\#��p$����ͺ�1�}(��7�KWϤ�Y����� /K���:~����W�Z��Xѭ�v�#+���1iگىaM�ىlZ����ļ�.�w��cN�`��3�J�i����w}�����Pt�(+k�Ñ���4A���"K5�;��\��jQ���0�}�g��ajF	��>���s��+���OZv zn��پ������,ޢ~L�ܯ�w�?ޜ����?x#��tϫ'��������˻��IO铝.+0��
�Shs�f��sqng��q cD;�Ɖ�<g��8�a���3u0)��Rb��"�����r���q���G�t_ح��w2��H�q�g�a������~�ߤcS���;�ߖ�~X[��us΂܉\���:�2��!3Z���Ig۽bh���]3)\�n=��c�H�q{]��W)vm�kU�񥰦y' 橛}��	����]�/���f-���A��g�g�!|�����Ea�
�B�K��ύ�6��¿��I��ק���?��I�F�s�SJVJ��3�Z1/K��t��H��E��B��oͯtl�����Z�K��j�ԫ��+Fuk/����L��!���Uh�`�"O�#��z��ֳ�Vz���yG�
�u�
5�Y?�����}0�<�Yq���QG��)�g��k�������?-i�Uv��^K(����f����x��iߏו����hb�����h��ճ6n<��◣Q�����㻾2�_�o�:�fH3���w�o������	����:����S���}��0@�V{W�|ߐm�@��H�kE��B�UZ��j\�7d��A����\�|BIJ;�r�΃{0�(��"��o����
4�_�p@ =�c
.ȸc�3i�|�$c�XZ(M���0xT����,������4M�o�>���Q�D�;>Li���os�
�E�3u������i���t��k�QPi,
���ɵ&�Q��&�V��&�Va֙��=�TU��J���zl�d&�%�8�E��,�� *�EiP)�*��l0�Z�N�S"D9#Z`,f誰+�D�����`R�tf#��4*8�Y�T��������zV��F��3)��
0��Z����U���=���"\|�J��*r$��������z�ʬD}�f�ޢQ�r��,7h�Vg�tc%�~CLN'�6p=��Lz�.�,J��՛�&�ƬѨ,j�J�qJV���lĤ����&>���Q��@i�
��+�_��+C������߽�߅�/W*�?t�+d�Wj��l�M��C6u�U��?h�pZ��Z�T��_%ר�����׵��kwd�+J�F�����ߐl��66Uɿ6P�5�P��?����P˃j�b�����Җ?�)�I�ʿÈ�.')��V|�= �J�g�:����b�(�n��L�Rs��?�\�ө ��R:��{�lQt�B�$ՠ��j���Z[��_ ��(�ȿ��Wj�)���_�)��*Z�7K�������k3yQۖC۽8(ul���
�L%����X����!�z0������R+��˿B:�������GtߖWG��H����yOM�4}�.��'E�/]�4��YZT�����zM=pFɫ�����!6��|��G���J���}ղ��t��D��V�JK�s�k��w�8y�w�]���UU�����L��?������sow�x�����/̼��x���piA�z�y�i�Ok�?q�|�W�/��퀓
�}ϒT�%�az�of�y�bF��9���z���?����s1p���"�2d�;�ef��=g9�!��d��?��u��ܼ���7�y]dr�H��w�X���	��Q�V�k�t�_�������`6�\J��f�8�Ӌ��^87e��-�\����]��S`��Na���E�ؽ����[]�q9�o�VE�g����W�wc�ɧ
���7�='ݣ܇/�x!y|�>驪��/'�<#�r�t��ޔ\k<v�]FW��	�<�6���ѱ���5���-�dR�����(�t|ĖtkF�3���x�o�\��zL����#c������D7:nC��W�������n���Kf�w�ܭs,��  $A
���H�R��\��~��#Q4�_f��K8 ���q(,����������?*�K�}�B����Y��/���_�`)B����Nq�H��P13�?�|�o��ʦ�����;�|��_�V�G���M�m>r�[�ӑUK�btʵ�pPMtŽOR�\�y;]��k�e��-���|rbƞ�/�\�/<ʧ*�#!I�7���d�m׈�L݃."c*ES�7������)N(L�SP�a�l�S��\:� X"
P <Bc	�   "�hʒ�� s����?����r��_#�� A$����/���֏��a_���@�<���������4���؛.�{������m�������ݸ��d��m�	��A��͂��Fs�Z&�E'�����\Ii����쒹��f�)I#�ͤő�����@���\Q7�Fk���.4��6�"����2kf�J�l.����&�6���7,��~�e�%�3�&}��*B��澕jƗ���5�SAx�O�X����x���2�~�����3�1�!��������-"�x6љ��K�M�Σ@z}�sdZ�8�feН�f!��� "�DAA4�Bb "B�(d$MƓ�db������ H��/����/8��Q(����\K����%¾�G����#Z��2�zY��.������n�u����,8�Qh"�B�A��h<���82j��<K 0K����� �������d�ϝ��0�o��ZKc�����/B�ѿ��~����?4�_>����w��}qa�B#���o�xr��mt�v1��6YR�7Z�wj�/8��
��S�8���u7���y��-}$�3���MoGJ��"��xq��E���
�)B�+��׭ث���'���LKC[�RWr�.ۏ�xzػ^T����m!D>�^�/��)(���a(h2���@��$$D�{�C�!�x�G`���?E���\��
�e�͍�� M����T��� �����-���cٚ�Z�vö'8�kF_v�ٲ3d�
3�'{
��.�����4�|C����G����E�.ݢ�NFpEE ����J��.�vק������N0Ҳ��Z�_~����C�E(�^� 	��,��� (��� �O�����߯�_������Ë�����#��o�e�VO�����A����Y��~U�'��v�^�Mh*����'�Z6���]Џ�6f�j�pq�J�a~2n"^�F&A�dʘ!L�	l�����4W�z���_yw&O�`�{ZH���ǧO��IA���M�ܛ����~N_�X�{b��H���Y��Q������O��#��,$�R�m����!��p��aa ,�D��Xg�) �6�O���}�?���/�����?�_�a��k���������� AX�������@���?
�32�[^��t�:�w�K���t�dQ�S�~�̃��xCԘ��T�kG
�9��߽����ė���� ��ñ_�+� ��/Oq؟��o�?�����ߟ���]�Y�����$�?���7�`��ϯ�0��������oc��0=�rɃO�M��-��_ߪ����G���	�g�Đ{�$P�5W�H
�Wfw�x��L3�&�;�S�^������Y�}�@��Bw�,ۧ
��)�0�:�$`���r��S�wA�9[��+k#좄�[���멒����'��E k=���˛�Bdo�&F�nNݶ���;n��v~�*��f��[W��gL�n"�H��ܼkKat7�V_����bu�k[��kkf�4P�h�16��n�?7������Y{P\g�Ev(7����/����QN��$̙k/�k{Պxߚh�k#�<�%8⋧�<<
GJRn��z�����/e�R��K!����	�B�ҽ;��L,�����x]� ��&�/�+yZ�o�w$��B�W���Q���~K�"-g�O�z�ۜ1�g[�?��&��ve�zxc��F��n&D:x�m�, /|Q.���j��R�V����?�jĜ�?f�y�M�.$P�=M,7
�M�.�/��C�P�k�@�ꪻ������v�Fn|.�: tl�lZ�4�{� A�V�6�cپX�۵oم>/�Wr��r���9]e���3s֪�@5;O���6+����2�U-��4�a���D�pd���ʯ�*�%�n$�'մ�F���|����-�����v��$�h�o�L!��8u{� ����*DjJoU�;�hln��[q�#&�ɶef��v��:
�h-�9f��c�8b� (����G��m}�L
����.���.�2�$���jQ����͢�r����/�ZuL�V<6���y�oz�΋�N�F���ɎL�sۡ�C�=В Mm�ۅ�;PC�'�o����7��/g�����ؙ#<
]�^ܕ�6�:<�\��wո��{j�TT�ḿɺD�4߫�M�� 3��.�S�H_�Esd��E<�dᙁ����F�Xw���2P����7���7�|,���)S�s,&���T��u^�Mgq�6�"�� ��o@˪�{,���1�D;Ѝ.0D����ƐGkρ���h/a�wt����
�[S������埰�|��~�(�����-��Mo�����g;�PX��TQ�J�˕�Q�
���3��ig�}�n]'��5�O	ʟ�{�4����<MI����� T�6E�|Ht�tTY"�4����p���▬p���>Q}i�I�k����nqϫ����,��d�#����N���3I�i�9e�0�l���p�RM+'����hΛhAk2:�</�#O��o�vxda��)������#d�����oSB�q��>#���5��/?ќ)v�~ߦ��iq5	_͋���w�:�w�����H���(�����J�I~�!-�i��6�Ȭ�GF=�,���a6�t5e}?Β�ӄ6�����ub���"2R�
� E�� ((�kH(Gz�:����9s�p�����g���{���3{~�׳���sC��U��U�d�8��6c��YgG�n���^>���y�9����R�(�v�Gӵ�Es+�y���� ۏ�2��魝�܊��p���=�X��1
ҹ�t����d^@�WF]�m��&U�	,P�g-���t����3����v����?
�\Y�r�~lԑ~@s97O���*�\%'�]'+5�B}
�O����_� �

����F m��$)
�����<��������[?������ߓ���/��?��?X�t��'��w�'�/��bf��jf��{y}�����*5l�4�GOF�D�H�6���WL\Ǧ��Xsl���_��w�H�@���Fhe%)�� m$��%!V ("�Z"�M����/�:��S�?=~>�?�_���I������_��}�������4�wY�|��ڱD8��m^]g]9����������Ǳp��S�
%�N2_�z����,Ѷ.��)b�M�#���	A��d������m��$��
��V�KR0
�k��DŽ�+bs	I��y|�'3��ݗa-�'�BO��-�oN1������i+�0~��ʱ�A�w�z������[T���+wTj�Dc�/+�d���d�V�n��z��]�.�p8��!�w+h�e+�� ��[r��u:I�Ij�G(�&�l4a�	_�%�0z��J¼�s�y\x�Nhr�jWf���1�,S�Zq�V��d��$F�L�i딦əGEs�uOm��޵�i�,3��I,S���hY��D�#ڼe3TC�#�t���t��bH�ԭ$syr�3"�	�m��ɤ���a��������ۚX�1B�ԗ����3�:<ߪ��t�O׎��W��{�]f���#\Q'ݮ��X�h�-�Z�܎��R
�[��	��L�	K�����{�^|"���#]�3
Κ�)�/��e��}l<�9�'yCv/?���΃�$σ�Ӕ���4=J�y:>_�y�,��e'�&�׻-W��f��5�������`A��#=��� >}�FH�Z����c�}�$#��N6n�[s����c�iA�?tC�|N��-֋�PI@��\񕡻ԗj&Mb�s0q���䆰��(���!��%�AJ1�U�|K�(���!��zy�*�������݁�N�D�'�(n��'�n����
�	K��;�Z5�O!��0 �,�ܐ�JjB_X�d�WjRS��(�ݒ�B�,{��D@��ѽBŻ�%���1�K�P�C����y�h���fv!���y��i�O`�=Y�|h���b>�g�ۥG��*S@��h� ���b��b@���
�
w/A:?
0}ƗO<�����:c���]�/�	]���jm0m;�+t�F�n!�!�hCC�"���^���wjҸ$��� ����6�5iS���D��/"]li�/ک�0�`��>�X�7�"%5ˣ-�)��c��<>N6��&�1��=�d86_(���x����3�-�k�;�a�q�w3�[H���7|���2^��D���:�hb��cx���ϱ�9R�o<Q۽-����L���^
`2]<g�a0.��֒�g$�͚�����#&�QKdj�FCW̫�.R��\#v��q�/us�]�����E��(�^#��h���v&��C�Nh�e8
�%�R�:����hD��Gs��ыy�{tn�'pR����/ʵ٨����؁&)��}� !��Qk���P���4*$�*t����<v����o(�p�4'�	2��#A�l�,�Nk(�P�g��7�->/��\o0��^�o�FZ��@��Y���{���͈�$[�I�����g�c45�s
{֘B����}^^(���iZ�/��6ńa��c^�(Ъ��`��iu��؊Uܘ����Ҝ������Ի�ƜխE�]gp6��81���b]�wZ����ީ$����@?s�c(9t�6�'�n�U��7c�Z0��C���(N��a�:a�����(�
.��y��m
�ຐ�,O#c}#F��}x��n-2�1��1����-P�LK��yo�҉�z�'+�d��"m���!?��g��Ӽ�ܛ�&��;��@�}�ޛ��o�zn�]l���a�,po�=�詝=�A��%�R�h�)k?���TkP+����$u/G���P�#�n ��`�M{���c��gd"�' �);=�-���+0X%����j�߿�����?����Q��[A�Xg��a�8n�[(�%�,-�?P�����?�o����ϟ��������$�?�_�������ܮ����?��������Z�3t[�O_�>��}��DP�gf
����
�@�������������=��ʀ�~8��Y����m����� �A���o���������#�������Eُ;{����׫�J�J�K�7������7
�_��w�
����<�z'�XQ��^)R���cA����gڜg����$^=��
����(���X1}��)�1��Z[2���y/y&��s7&G�>�2J��i���bަ�_����C�!(���VF�ݑ0Ė�(�GAa8<������/�}���<����������O��t���+�?����V�	���h+$l��O�����:����̻v�ez� �s��cIZ�a�%�~�^����m��_�uV�W��΄�O���=i�;��e�}�?�9Z W{C�x{-9>�J�}��u��~��\i�ɸ��e7��>����>�9]+��k�t��i��<�͏��\����&-���W*X�y�]'��U;0f�[e��B��s��:g:��������vCe��z����έ&�ꈧ���-繐53�>����~y��X7�e���D<�@��i������|mB�����Co��B�a5���US�=���c*\Kʙ�#�馯~j��IL���
Ut!(� F�M�Jw����_��x�oe�2az�g�0pg������>�L�#�Bk޸.��D�T��`�:���"�<�/N'����3�.-x,�B�g����8��$���:Q�]Ԕ�)<�����蕊).O��ճ�ʛ���<H��+�r�M1�e���9OJ����Ż��D�W����:t]@�c����#�	]�j]�^>�T_��J���^�l�g�j�Y�^�K��B��ä��U����)�D�U:�8Xٷ�\��Xe�nR@�GOW�}bDq"3<��rd��Jb&�~�$PјJ�3~�M�w��q"J��[-���45I�y��ݧ1��u���Ty���g�|^|�'}�N�$|3yP@�?x\fS�ܵ�>wg`n؋i���?H+���-����GF0�
�К��LNr�J%
|-J��i�ۍ�5S�T����U�ݲ�<�E]-xk�e1.S����gO�+Bx6�,<�t��/�"�H�%d�5�k��1��,�c�o��f�/��m���G����C��.���F;ts-b~�	#(�N�(ll�_���5R���3�}�f��;�.���?�d�_�Ao���3#=���*ô��4���>M9�]��mS����l�q�cRl'P��ee�5����������҆V��F�52/��9���1�C�+
<-&6ؠ=��H�SN���n��	�z�����l!����)��[��r������B݅�mʡf�4'Ad�2!��'^]#�_I��Aް�j+zkR��~���c��e�,�Ǣ�#����5�hkwU���t^�9����f�@)u�j�]Q$rA�����i^2��$.�I�u@:tH�}u�k�����İ���O�FW�ή�ކ��+d�Or����~PS�?����������u	���>��P�Y�>ݠwW7����m,�/�ˢ�[K���N��g/'(BQ�H-,W9��4�����
"eSe�%�Q��t�l�"mS$�. U�1H����� �$��o�;�}f�=��>sϰ>�/k�Ok~�g�y�y�����eJ�S�=�ٲ|���v	�w�j�]��^��=?
�
f��Pa�Ֆ17���� �m���`���C�R�A�I��L���NY����κH�]�mk�Q|���>��6�YĴ_5�ߓ�^�O�緘̱o|v6P���%����D��! 7A�>LT��m$�B��RܜSH������|;����f��~�$*�:�KF��?�m+HZ�UO�*���<�s�t�w�#tN�:(��FZ*vkH��a�H���ٺ^9���2:�� �՟{]�ˉ0�l���V�+Y<^�{V��Hf�ƶ E�U��y^T�'��f���I�u�M���Q�����2jhA����1�ٗX���6uL������<*^�m��+��ZM��̡�}dZ~X�����q�����%�:y�Я��Ppelk�)����kTA}�k�.H>N��n�[$���/F{
��b��ѵ#��l;��W�.u�O�P$���U7*4b��c"�OȲ垵� u��#�z���t����^��q#��f.�v��=ky�z%B�u�v@,�[�h:eD2�=�Ե���J��{g7|�
s�"#��_����q<8�7��˲�BϞʏ�Q5�0ve�2"�T�˷<0+Ӵ��)H��q����0�|��i:����J�I����gGD���qS��)|3�f)1���S���b�!{
{J�EQ�v�ERDG/%go8a93T�C�w�N?A�n)�c{UTQP����d�C��|�ݷ�`m#������΀��=EoC�y�o0��f`0�OqVyAu%�g��xl8{���-���]���Z�;h촆�S�e??��x��HyX㩍���D�@L�i��d2P�*���)@�����ɋO�ό�*'�H�m'D]���ҏ�4|_���eM���##��m��"�Ʈ�v��hVk)��޾Gp2j����Y��i�opx�6}(Ut0��|�M7����-m�l��D:�\T�S��^���z�fL)����QG�����%�k��꒠�����$Z�"Z�]����`"�U��x�h��|eN�R��[��w������
y�C@�l���O�vP:�k(��l�E��;�o� u�+�7G�T�KcQk�'UƄԐȳ��ay��K��A�X���
q��&��A�l�'LO]dc���@�Q�w�s�N��AG�n� �C��~�
�e\����70:k$>�c�d/ȒQ����Y��l����]}��j��֐e��i�ݓJ\Y͇֧��|\��|��"極�KvOY��ϫ�]Ux�TD�3���������(�sa=nXE�o���d�wk�;r���|�	>�2~�������?�����$��C"�@
J`��!��A�P�"�� �����E�3|���3������o��O��������� T����O��?�������������,<��_�����A��P{�\���
+���r 8�!����w������A@��?��
���?[��3���(@�PEy�o���!��0H�����)[�?������/�����?�4��g�A|�a�|�Q�[Fh�qM�݉ߝ��6��&C�z�zSY�,ӏ��66�������������A>���B��:շ<5��w��X�X "��m���W�_���$n����l[l����-��P]�x�Z=��؏�+یc?ߌM�rRj@�Hn�iT����լ�<�%
R@"��Gb�(*�
�$��� r���\����������^��� ��g�����_��i������Y|�����H�[}��t���g�3@R�n�յ���[��[�n��̦�{#,1��<��Ĳ{�~�h��݈9���#{��qNT�g��g������䓍��঍� j��a��~@i��M�8�M(�{>̙�A����RC�A�L���*��d�͑JgN�JW�0�m5�D���(Ӹ�@�?|�ߕ��v;��_d�
G4.���$��ԄW�����љ�2�]�?�����
I�؝
�;�q��w2�\�!O	6B�p�؞[�yT��Y�b@�e�����
�;�X3���������d��<K���jd��5F����d��L>�"n�%T��=BD���}�D��@۰��ۊ�j)8%��O�u����Z|��ol��Ŏ��g��ѯg{��j��`T��?zn3����;�z˘�H�hz�s|e��^4u8Ǜ̹ɂ�"	�"&־>��:-�}!���)r�K�x�:Ct9����1Y�1�����Z��$=/�Ôo���nG�DѲq��5�J��d㶌3Cn����ik�����qhd�Yl��`̼Xn���dBg/#x�}^$���c���T3���F�����mD�ُӞ�"�#�<���b�q�����8ؿ�iC�����R�G/�k�u=��*`�.T�X��Ŧ5Ɓ�/Ј�
V�YT���,8c��=��-��e/w��b��w["����N������/i�}x~����`������v�rs���	�s��@�ʃJr��]6�\����G�U�f�tl{�e,������Į��c_kBP�qWi:�Y�t3<��~�a}�z�#b���z����q�*u_�l��|dR������'��$�v�о
5�����b�h5�vs�E�	:�P��og&B}%��gS�i۪�S��hL�V��ys/]�H^����$�nɀ�c�[��q�ƥ�U�):䚌ˢ�VYVn
�M�}����vQ�zp>���8����׷^X��\���x�mGU<<��%!��g�����t,o�v��j�*#bNT�-�bF���<�kd��(���a�w�F��QM��6�C�1GU�e�*U/W�\���^1-�3�Ն�#��
N2����RD8StS��n��$��;G�()~��� �W���$�}`�[l�^ZU�/��\gw�F�X��� �r��Ux��[�Ԅ����G٘�z�|j�υuq�?!7l�R豗L:#a���HRX4�uM]w���N���]�}�ۤ=:+Kav�2e�nAAa]|�ph9���0�`L��9i9�v�Mk��u�c�G(5��!!��T�TU�#��N�i1��[��R+-�rEX
�����w����E�dx�O w}q�o7~f�U%
dd��z�}��H���V����B
���-F�c��bZ|�#)���y��M��cc?$�}�4EA}^�#�[����q��ݎ�+M3U��ot����Q�s��I�5�����+��qZ�z�U�f
�HG~
i���-�	E�ak��b��ϓ���V���B�	��ލ>+�԰C59�&���+�6մc���:p�)F6.�;�u>0�
�Tw�z��V,�p���/
'�+�{ۯ;u"�pJ,v�
&p�"��10ҍ��ή�k�3���?aa+ � <�>2i�h0���͋�����ƫ�Z�D^�h,G�].��71�wԤܱ)$�<Q�tn��OA�v��M��I�5��9t�� ��L��nt7�lm`�o�65��W�fO�%�=rCŝ�����R��w�Q���<+�u2��
��e~,g.Z�S�6�-��_�f������e��L��Ty`E���9��h��S��i|ٻX�EG�S{"�������B�W���Qs|�����\�i�w�-4��D�d���吻���(3FmQ�s�e�n&�=3"�g�e�Ay��UYꞆ*��}�*��4m�wǈY�`��}K<Q|��7��\�s�X�T-K7���l+��UK��u��WKko����Ö�P�ߙ߬��m�]����v����9��yC�����q��s+\F\�ԚF�<�1��Bv=�HE��*g�Z�{P�P���хN�sw+7��K��;k�X��.�@5�q[e�@�L�jV��J%���7!�(K���=�=�����nc�?�ޞy�ѣ�jU0�ЙI6ȽM�b
#�Q8��{ݗHd�x�� �WR�):����QG6��r���9�	����*~�e� �Y1y?����"i�H-\<k)Ps����>6������c^�`��Ѻ.�%�+�6�_כ.���·�	Y,��A�L����J�^��&$��d��E	����I�v8
�A���y����C��+���-��N+����!�}�A[%�����vi�n��-������b��#rd��5��)>NO:a��5v�M�ȬP�7��
]	}E���m��g�YH*�ZZn�sl��&$�W���M���^弫c�:�2K�����A��d�c$��f^�&>a�v|v�0s����lb����^<3�'��(+E�K�5e�kݳOߦ��*ǐ��ltl���=�'��%�s�R�.��f�cj����ay/W�/M���.[�K�'m�s.G��\hH{��;��|ʊڳ�6��6�u *,���a�l��`��]�ֳ�ȳW�h̿3�
�h�ae*L��i�
�oM%��Ru�
�v2q4��H��~��.����h��pK���W�e�����L��&r����B��y��G]G\�ƌ�����'�2���Qn�9B"[y���ub��%���>�5�
U�|�Ǜ���{6�.��g�dY�獚,�F���a#m>I�^[�p���\)(^-y��307Z2�e�߄M'��Eu�:%���B:xfR��d���԰4����.�
:Hj(вZ��s�z����=I�+�8;�gQ�G��؜E�u���z��j�]y�c�f�{�g;/��J_��9��i��H��j���f'��Y�Y�KO��o�
�x�%�ʬ-�S<b{��l��$[N%������ܼӞ�Uی�^��~��m��*3�|"���O�@�{J�YF�];���;x��=�s���HI��T�!�/���jlk4&�aش)�%ySpS�}�Uws����ăw[}����ļ�;OG�j����}�g2�ŏ-}>M��r�W<1���4�c!��vms��J,��Zԩ� �L��g��ʠmv�\!��ͽi���!����y�>���B!Ea�c~"�ĻS������l��(m��е�G�ZK���G�O�����z2@U�:+��; �����%�B�Y{�*rp���>�%�z��qڶ(p�z{��*3ם���4���V�S"��6WB/sf�=����7�s-��[�"�TeO�D�ǯ��3�׀���@���q���7��]0����9�U򺹅��ro⒳���-��b���
�P�;�]��b}��dƜ�{�����т�$�Ȑ�b�곌��=��dp�b��l<n�!2>T7��ڨ"FN�SO��&�/�K�z� ��.R����S��&)E�-�m0�~��#_���۔Co��"���C���o&�?��9��jq�]-]EOA������B�3AN�5L�^�|��[s�t��$$
��~o�=��u��&nT��+�2���mjWeT��E���b�����ZWٝϹ9��e����ؤ�@�t�l����	W���;�i8��<��g���]j5IGeWL�`z8�F�[��r���l�E���!.\�i�Y�i�ؒ��p�g��횇��{�����`FLg�}ǉy���x���whkB���:)�{;���^ܪ>��c��S}�fv�m�p���6��X����J��k����y�9�2
�[5��7x-���ەғ��h
�S�j&ts�E�m��-�{��\����u��}��<�L���>zg�V�^�u�{C��z��3+��O��q���i(WVw�;g�c��_���N��vqZ✺�6ܻ�usT���W��4�*��U�my(�䱥�G�QK�)BoZ|�y;�!��Lb�F�d�o:{���SZYa�4�����۪ϫ�,?�9E�ޥǭ>Po3��}��""N�����֬�'[�l�$EG�Wyr�^
��������E>U{6��aF���7�����N�^p����@���%g�d�$xM�\M��~h�����Ρ+47��f�G��aU�1��	�d��f�h��	�$�N����g��*{"�<x�����kY6��/X�=\^��,�_�XBT��{��\�.Z58\:r�>�����`'���ɹi+ɧ�D���k�ƛ�/^U�^��.�5Y�뙮T/_<�f��wu���^?�����(4�>]!��F���a�+c�drĕP��R3JB)ZLt ��@1%Y��li.Ee��t[E�8�|��m`W�߶�K{�U*�۔��t��8���`b����b�t�̡�Q }�L�@�+rJ��}�C��g�
�Ƕ�#E�#mM
���L���+
	:JI�mv�
�/f�8����;�I�F(�x���5�/�O�J�� g�a�^w,�a؆����89�6�4�"�Uc�mC��#E:��[oF��&��M��{��)/(
�T�m*٬�䭏��)x��xߓ��a�����3#����
X�ri|�zTl^u��Dp0�&�V}:�m>����.�T���d/܄/t/���Lp=s��*�([S��J𱵉��V�K]�ǥ]�fŢ�+Ct�w_��<֮5~z�+�a�)��8Ւ�2�E,o����j��?��
r���Tt�F���2�n�q�(���qY%57�e6���g�nֿ(d�Cc'CW�k�:�Ck��^v-s���i��q]%˓���Ҝ��[�W���Ͷ�/��ߵi"i��k�����<q뫢�s^S5s��0�煒�����h��l�7*yή�M���{�Q��mO~��ۥ�i{�=�a
L9��Xo�X�����m�JK�Ҁ�P\5G�?����[2�>,�Y���q�1Z�+���5x=�g�$o,'���s����(�0��:U[��h��CE�v�+N^٣IY�_jBEZK�-}��¨ve������0?SF�a+���X�?�XdF��7���'�)�v���ߚh��G�.nxLOR���u;�\�_X�QN1
�K����2�2|��kH\�Bi��}Q:�i�*�������&���#���աL� �V&��I�H�a�N�P=uG�������u
ϊ�-'��|u����k��y�w�o��Eґ 8�>���ifĀ���V�7҇iE<D��AN���IF�ܬ8p��̽�o�^���<��mO��[�%X��;��,�p�y��K;n�i��~a�V\�Pm��=&���ժ��	G���w��=ZMӋ����#c�)`pX<�Ž:���XHp���G_jp(f�Pn{�ܮ�"�O��y���@,�\��­*%%�
T�,q��Q�󚟼{|
�BV��aw*��fA�������!�b��tn��h�� �[��c
D��D�w9|P�}�p�Ќɖ��˓��+`�-�a�
��B�3�i�+{�FX��W= tM���(B^�yEF;�'�v�~�a�v���|ѻ7zz9�^���jj��&�^�$�����=w�f��訵[�i�o�ۨ�p:7��N����{�3�U�!�CSD����G��Q�o�q��u( B��%{���.X��W�0͸���{�e�I)2<�պʳ4p53
zߍk��!c�]�F�i��hM�E�K���+΁mgPǕﮝ����~
��
}`��R�p9{`o�!l�~Q٫J�D�t֕��j5#�1aK��	���J4����l��;���ȼO�!J
e�#wt�{�p��6V���/�)�ʧ8�dq���&��|~(���n���
��3`�#��V,�eoW�j�7����OD����2 �M�*���+�^A%bO�0�ϡ��t�����5����R>���v��^+���p�yk�^�X&ɮ��^l=I�y_��M�%)^��y��h�ѯA��D��O�Wo$�#4�c=�!ո�J��x�Q.�S�X[���[-[�!Y�����x59|N�$��`�O_%���5<���3n�{��0x:'ߦ��Qp���(l\́ɝH�R��ϣg���>zP�9zh�n5K��}s���qd"��@�T�nv�<��'X��Bk��P�	��
�))DQ*c�������o�a?"iOe�ȣ�O�:�ᐺiV�h}_������'ʀAN�1�뇔��.,�TU�U��&Ir/�ٓ�KK�1�h�|"x�}Q����0܏]8]9E�7KA���*w=0�7�^�E4o��� ��__��
�á5��GG�T��E���u�p~��I����ݷHF^Vt��tUѝ����P��qpt�B�.��rZ��j�k��ǳǃ����\�٣c/�׻�٣���sn���l���]�����ܮ
��ǅ��
������0�7�=�"m/������;���l�D��$f�kt��;ČV�چ
J���y�Y�����-���!1�a��!�e��o=g>�n�<	\�޵�^�.=�+��W��X��uG�]�U�yUg6�ԭ�ѓ��>y$�x� ,�A�$�x�%`�U�U� �K�	�'6>�*�]K�9�R������M�kO8U�!�ޢ��L��7 -�3_O�k���Ĺ�!UΘ0�|1!�Tx�z5�\R���p
�ͫ&t��k����������>��V*W��dCUF<��iJH�z#/�$�^�t��{d�96c'*���_�uwmv���f,rN���� �]!P]z����3A�YV�����a��O>��|h+l���SpS���z�M�+<��[�^���¶Mүw�c�K%�ƙ�=�#��uJ��:SA�� �bi]��Ş�d0���֩+�=��V��Z��L��o�11 �[��&ti�'Ȝ��e����g��8p�N�h0�@B"tӯ�����E�I3�}K�y�
F�~�_������cc�>�۔'���j���U>�o�6Fg����\Gx���?I^�un�4�gފs�b�Q�t-�I��|�s+`߇/�kS�T���W�ǣ�[�2� x��.�ۑ7���x5V.�}.�|�Ptzw9-�iH��9?�����u|w:�'��΍�����,yZ!��,:���M�s������9�`��~�itː\��Z�E���|����9���@��b�"U�/�wih�)Wzտ�V=+�"����/�%/m�R��Ԁ�A�)OgG��f����ݾ"�G7hc6;�Ŗ\�f���5�E�����#1��>������!����Qr�v��	Y=|��NB�C�E��X�zvz�*�v�`���	+�JW��h�t/l:��Z�QB��6��GI�8��4����02f��`�E��WL�3�cSXg3,�3x�7��(�O��b(������r��N�%��O
���p�O�
�B&Rj�QBS���)��!�D��M���;���eC(��r;��f��0ƶ��V�
ԌOq��x�9>9��MGA���I�e�������H����@"U
�&4�ē_,46�8H�jt��$b0}ʌ��V��Gma�J�-}��O�w��\P�R���gr�i��%��/FF��_[�7��?���4�}�G�=f\�Zb*Y�]����PSNA�d*ݫe?��~�U'�_X���;ʭ~۶l�������FD�ʚ���.��$��^���tJnb��b�p����2�᱇�����"�z���Aw�??@���
����s�>;P/T:T�yƏx���{��5��:}�����: �����J�&��8w2w���4·�H�^�u�~L��~������d���,>p�'롍@I�!���#t�8�6�(���P<�z'�}�3�g��
�@x���&sp \�[s��럁w9(��ӷ�M�5N�L�Nۺ�K�j�F��K��q� =Dj�D3���c�������LzÁ��W���Β/���;ǅ�K�Li�w)Id����Dw�W���~���T��-2�R!U��a��7��kV�������3�
��r��<�Ne� ��q&;j���_���e��[��&j9~VZ��X����yD���
�Cuw�Н���o�i���'�����c���q�c���/����8銟L��'��Ww�v�+ڋ9�U�����"�W�-�����en�-p�$*��k+�}�6�V(�y���)��~XwW)��ń��#��f�p�ub��N8���//@#	2�U7�ܪ��>n��ӵ����V��<5G�@�T�p\S��"�}�(G�w7s�������ȠF~[�����r�����㯈ƍ� CD�ɉ@1N��Fn���u
р $�	�6�O�Kk�����q�U���
��cqw79�-7�ƺ��."{,sj.8bLc��=A�$k�}��?���A
�/N6�n��l�t�C�b����A� �z�`��Xl��c��y���3׊S`#D��?mLlv��J��J����|��5&�	At빸_d�`�H��r�����n*3s>�SX�Q�œj"����}{rnU����P�9�P�]/o�U*a�s���k�Cy5��U{��7L��I����z��=v���cwԎ���%m�q\T����ч�f��E��Y����I������c�W$X��b$-��Φ\
��#}Л��o>��� Nc�C_��������?V50=��
��3#�
�
=�2dRVcQ�3��21���w��w���tL��������/������|���3���T�����t������������$h�  ���K���[������
j�KM��Z���E�u��Z��?��g����b� �O��ty����?3-������H����D���ms@K����B8�������E�����O�?���R��������SCU�_@�WP��J���ç����b|�!�������1�lJs>�7 ܥ6`#�K�JHr��??9!�*!�!	!	��;or��`]u6H!���Ⱦ�(��AP�+�!��]��q!�������jeecUMf�?��O�?hO~!�^��?����p10�R3�0�B�����/ZV �������������3����o�����?��O�JWK�̒JCߌ�rGp����=��A�G�?#����L�������ge�f``23��1����"��n������������������_��_z�����XOS��� �7��������y���HO��\L�,����F��
�ebf���;��/Q����o�d ^��?u�o��׽?XYEKS��	����_�!�ч�zjF��:Z ������i/������ea�Y�YY�,�������ZF�����w�����S����3�^������L��l�~��:	M
8��,=���G��9} ���O?���|���=�s����щC���v�J����q�9��,=�]-]�Ӄ�S�Amb@M�]���s,�� ���R�5�W:��`$�},qf�S�N뜭	�s�u��� ���
� /r�|���7x'�C�\����7|@������
����Z&�`c)Q~]}�����	o
tV�T>(�|0�r'���c���(O ��A�I�F��AⅤP���B����م����B� J'xJ���!��b�PzLsQ��~P���i{gu&!mNA��d�����O��"  �&Nq�Ӽ$2OЧ�N���xNyv!s���Y���)d
�������2�諙p!����
����q���o��?~gE��5�&.�ɽ���
m����dI�N�R�4�d�
IO�C[!��I����k��||��?�����ǚ�������d�s||\I�A�N�����% ���P�H�0l��e������ʓ�;{�Cxz��
�� �(�Ѱ10|��O�F{�m�N�Id�*���}�m������ӢEC�@������G�|�=���0%Z�{���}*����i���\�:G?�0������d�Р����{��~߆ૐr���<��b���]��
%96�?𱯧�t��Bh8���	��h!�������.����.��5׏�ш?o<�F��g�>�ΙΞy�=�����������-���߷*�<:��W��N��ΞQO�n,Ϟ����=�ŀ���
p������,촜 ��1f�)��3�g�Xg��.�W/�}������d[np:�ߠ����S~ǧ�3�VO�[��{�����	!��������xSqvNr���uv."���Fx���!+55-��[�Ξ������;�_:���q���q~�X�����+?��E��=����X?�k?��E�����#�Ѓ�ڹ3ҏy��#��������#qT@�/q����<���gv�"~�=����+�����~\��~�������vR�v�3.wJ��:yqj�O��E��~�����O|��٢����}޿������]D��������-��X�����]��q�S�����.�]l���/�?y�un~�.����}��w����,�����
���!_����/��O��M�̯㬺~�g��>�����o�������yw?%C�g�<[��O���S�*���E�t�~�����������s���>���!��%�\����������>)��4f&�߂ 5TU�T�
y�����ɄC؟����ۿEj^��֟�Il�O
���I<��$I�A���%�� ?���!,$��`%14�|�`0��0ٵ���$���۲���=�.Ο��
*��J/���Tz��R�Tz
�O�S��*͑t������a׉�&o�3A�Pv����Z��cPCp��!xL{{ ��a�<����SC��l�3�O���9Q���E��
��Ty}��sDcOE��h�H�
�D��[j~,Ӫ�*�|�#�W�n��SBcA2���4�i;��Q���iU�!$��V�0MF�R�=�ѭG�k;��e�r��E�'�yJ>�Ǫ���:}�?7j���D���E�?��������ű���c#�=qa��l;�"�O�E���Q�4�c��tw��x"���Zp���)�?�����>������8�y8<�`O�xGޢ���-���	��ԗC2���p'�����9�3	�]@{���/c��aS�-ed��+��� ]Oɯ��w�Tu< �������j5��uFn?+����R�%����ۣ�����,�K&�6<>�V�d�]�7����!�;W#_���ө��L�O�!����	������F�of#��V�?��vR���74��`��w�~���HCG�]gE��g��)�k�l
�[y-�]��u^�m�en~�?$���o�
e�ELZ5��(\k�VE��X���Z�HL���U��FA�ZG�ǎ
��� �k���e���Z�@[����Z4�ut,
��;CZC��+Z�\4������Y%u�U����[\4�U�>�Nc�h����4_�B�r(>��"s�)Q�h�)Y����߆�Q|�Ę�5�Q��%��0�
�(s����Nk���/CӞI8'�
}2��!���hXE����r����GZLbL��bG��b������kx��G�E{�Y�������'W��ܰ�R�g����w�]��3�2;o��<��3{n�����}�?���\K�u&8v~NN�U�����z���}��yM;�����α̶h��K������@���!^!�X�*��k����£~�io,F|� |!�]9��)r�/��'�"~�C�A�7���;�0�JO���Y��2�~V�oh�-̨���9����w��<8#�m�U$��[���#�I_�/#��R֕ܤs�M�%�O�Y���[f�-F��^����v������}H��!TZH4n��,?+Ե��nr���-�=��nwIvwg/q���v�������.�Ff�=Fx�Bc�Ů&
t)�����q��Q�jgFu�}e2�|����_(��t!s��u1h��~����]���Ll��K�%�p!��	�!�� 6�>B}:�v����D�lhAS8g6��VN��g��|� L]M�-1����Y�̜pr0e '��ᡷ
���}�PL|���+��_�(#�M�gIL�p?�\������]tsB��O�9��Bv�P���/F����s��op}1d������ߊ1v/ĻEԫ$��]bI#6������MO��;�2|����A��͐�@��M�n5i�fRڪ�tGϊ���
�m+��s��i�q�\�x�l>�w���l�ѦG��h�Ѵ��)Ǡ
��TmPێ]�_�u�Nө
1^χ�
�F�+�$���A�77ݯK:���9	���ϢSE��G�Lp���}�2{2�ncv�(�x��0�4(�v���#��%0�`�z���uS���乌����\���{E̺�MDI�����/YO��$���
��-Vl�+��.��5���ZU��h�eƱ�Ső�rㅆy
�]�yb)39R�1�_���V�D�;�]�-rgQR-�-��7m���̿��E���R�[y�yɣ+��-[�|�,�83���R�i^��@�2��EL$;;�u�M����[�,]Ҋ �V>S��#�]˕P[�Zr�Z)s ʤ���B�	ɨ�R5��`�:?�ɀ90�l�u:�j#�<�CiPQ5ф� b��{�ם�J�Z�>T��"��c��XGq�z�"cі�-���Ѫ�
��YL��*޻9ظw]�������!��*h��jh�Q�6��f�/��x����3k"п	��TH[ �s ��$�"I���U!H�"�̐ ��!I%&IN�vIr$��.IV^�e�>饎>��]aW�5��JȘ���0��&2^dSǋ�����"�d��ŦՓ"xb�O
e*�<�<5�gB���Q0��ϚT�[L|�]�%�QC|p�G�����>���8���S	�g����D�<d�����X�f#nt/Q;$'	"����9WB�3w,��!v�jm-��u�!�UwX�j���w ����e�9�f�ZO�PL�ܣ���K�>�b�/�3eB�R�N^J���E3����W*m�4 .���z�%��;#1Z)S���$��|a|x\E�
&�XXvXN �bj"/4�q{��z���aR�lxCO�	Rt�Y���+�ů4t8��rSdq���RTq�����Ha��d�N��&�[<�x~)X�P0���憁�"7)#Y9��F^i�+��1;�b�8��%D���.4iw����o�����^eN(K�4��Av/]Rh��T�?�y,��8�O@Ka��>k�b�*�Dk$�S%гb	1��y��,=��b�q�
6rŢ�+�:���P��WB�Enc1
�������?��Hs�D�,�%H�ǎ�E�>��
����u��Z�n��|�K�"mG�qk3�I�^h����
�,C��DO@܎e	��i���Fc��ũ��˕֫Ji�Zn W�����KIG����o�ff�D�U���nF�*��J1��K���MÚ(���6hOm/���h6���=�
�@_� a���7ߘ`��Ѭ"FkDi����,s"�cA65�W1%�!&���E�&8Ͻo�����N�H5l���HKЗA���V�zt+��9�����׼jR�y�i�̨��<Ҿ�V)������{ m����I�f��MA9��[<^g������F���T�T�@�ނ�!�ǳ�0�g]>�b�ļ��YQ��e�El��+1�j��y=�'pL��`]?�����>��e��N'~����,L4;�T�}bS8�����E��t�'����i��UDV�]P���#�O�\�ӿd=�*"Ṗ��"�ӭ��t+�-g�"�Zc#��=jD��[lX�(c�´8UnLS�v�H�D9�f�`�}�7Xq�{�b�_g�	g��\�G��
���Yc��LXV��h�~�E�����:� �d�m���k~�yD��w���w��%���D���]�sE�XJ���6��)�v*�v�����4VR�8�XW[�����[�
76QŋPyի�@#�Q�Ҷ���
�"�4�@��&ן�Dr$�����mڮ�l�g���:�֮4�Y��5k�\ij�/�U���^�Zu l.��	�֙4���R4�N$G�d����É��-^��^�A�lg7]��_Q���16�F햒����^B�Y�qP�qv�g��b���͝���[��!�A$Fة�@�8y�]O�� ��/�rGL��.��zn��IV0���׽@�)
����<�c<8���dh�r�sy:`�^�{���Т ӛŵšƃEr����͡F�F���+1�6���]�2o���˄o���Dߚ]d���dR��}�-��0\�D���Z�����(��d<̩
bc
�D\�w�!(����vQ���N,<,8o)u^�_��ƁmD�4	Pzז���/ ���3�� <���ڤq�H���ւ"\���Nl�X�����_�aULTa\�g��Yc%��]__ɛ�X	m%?[[+]zÝOE$���&}� K�dZ���DBĕ�Z���r��s
��X��n'�gs�@\I�����MlDq4c�
$��z��ui֛��~����L)���+R)$��a�:!f�0����}=������gh�8����6T��~��R�_���y�SWO�y=M][�=��'��q�3�]y
q�~���Yu����ru}0{ցD>�8c&�⚈4�y�pM)xI��R�b��D\OW�S����G4i�aE|����S*ߋ���h����\J�ߌv�_�
Sx�l| �؅cK�l/�Rx�'ŋu�!%�;����<ӄ����fH�� N�E`�G\T�!�R���v��@ܠ���͘"T�9(�U�C��l1��u(r�%���RH/e����7��ۗ�gl�y��FI�~@�9փ�R�	q:U�|2q�C��a�f���l؋#zMQc$�H��\u�_�D��n�a����!��Iz����N�W͑�EO��LdC�h�
�K	)��u�%��X����#FD��Y�m�L`QR�b#�^���6�1��f�'Tf(�8d���`e�:�`o�{5,��J��	ҽE�{	. 1����։����Z��9��"b�Ұ��@"MD^Y}qN<��4)���)!�?O����"!�e^,�?��K��I|3jf�D�|����~,Zi��q!6�EXs�!A��gy:�XB�sPC��w�^�E�-��&��<�$���A!��_��S+�����`�_G��e�&E�H���'�xb�0��� |o�x=���&�N�6�١ۮ��`c]j���OKs��sx-�yn=��L�ba���:�ʴ$t̪<%�	��^u�r�E>��f�3��fY���T�����Ѷ$6��,��t�8�y�3c<��^�3���p��J���;�[i86ZE*��_�rU�ς=�9�r7AfI� M{�x�7����!�T|k`l������b8
ǀ^��4\�?B�d��tHS!)W��~��^G��sy�Y�8�%�Y�0ґb��4���^��	��׬�b�V�}%����"��(Љ�g_��q�)��e�����E���n��/?f���M�m��D�s�~�_`�k�4��}G���P|��}-6!.}�1j�f�g
^^^��K0蠤��(aEL�H�p�NGS6�IE����v1}�Pa(�c䔴VB_Z��I� ����t�ZY_���!wȟ#�놩��)���%W�]ATk)�C� 3��L3tց�C,�F���b~��i����yC�'�Jm����hS%^V'�8X!�	/�������2��৿�(�1�4�������H����w���P��ޯ������2�M4C&
f0f��Mȣ�.vZ�0�`�
��~!n��M�Y_�/OB.�_>A��_>|�Ç�A|�6�}��R�놏�@��lQc�x�Pv�x�$�W��U	qi.���~\Q^�V�^۰O�C�Jm�VP�>h�mد��W�6,o���_>�V^A��6�[�B͍yC�[
Xy@�Y�E6\����#.UT|Qa�j}���"��4�/y�"��*ܺ���!Ҋ��J�2��EVsr���sg�)2�ʦr����v�C��ؿM$t}�;���xHȈ��K�<��qy�%�$�����bQb�OC��������zJ�����+���"������zZ�� Ջ�(�HǢbb�EE��N��(GpN�m
a�j !�Q�Ŷ�p^��	�a1DIl�ѽNS����@�g��-��Դ��y΢8���7G�:�(��BS�*K����u�
��_���鹨C7?���L�iQ�%���X�aѩ�"��@:gA�4+�hU��u��9�?�T,�������z�w��pVw��u$��"���u��1&uE_�aɈኈ�,���uf�SˡWs���Zzhϟz���(v
���Ƹׇ�Y�y+�KL�� ��[��A��.�$\�,f�G��#���N���<��!�xx�փ{��h�7Q����22�@,��xo`0��aLH��I��!�nE$��Ql��j�YL��M�������xa�!�7R�"|?\�w<�1���x�M/���@���"�w)Jq7��>�PΘ&2>]x��{6C�wAQ�]P}���yx���T[L%�-t6x
�9桊OV"�&kR�l��`�A�T�~������(���4d��}���fX��~�R��;�V��+ :�)�����t�r�P
(�,�	��oY��D�<�3����;��U32
,�2i���p.�K�hc��9�Au������7�|�jF���:5���\a&�q��?��#�ϓy�|f63h�oz��B
~�>jq�̬�z���
�_�m������&�����]
�[�zic�	�|�8݉���o��/�`�7'�"6)Ց��n�׆�Sx����ƪG�L�l��]
%_K53_\����c�݌�&�ڝTr(�D�ĶѤb|�E����90\�}��j�l�jo4����m�M��+��{D"mH�j��G� �n'��6*�"��*��É�O�S�%&��E&-�E�A�&�
ͫ����I,���� s�=jӤ,�"��[��
҇m�`����\QP�%>o�&S�����Ͷ�<y��������g�V�7�Qe�����r��1�>�E��ʪ�U�r�`����`�xҎ�C�#�ͻ�}*r�v=a��)�l!MR�����{H�F}���IT��EY��DMd�p�W���zۮ#~y߮�@�;AV�#r��rw]a�&"F�\D���dUM��3�G䠠/,�:�c<��94mz�I�� �:���x�R$AJ��7&�Lf5��$�&Jʰ,To?T�f���
�y��1k�K�Z�#U�qy��R�-����l�[:��%�H�$��i�ls{��lIb)5鈪Oba��N�Hd�1��9��2g[�\�BX1m;$I�]RA���F�'�#���b���|ӂ^G�]p�`o�d�ى��o]�.� 7i��2�R�Y{
�7w	�ѡ�6r3	+����� �q�ҾV�2A����b��K/��QOVϐ�=�T���w��l��h���p��D*qG7{�2�W�'�e6%O,Q�d.Dı1�FG����S4�f��R�1�	dDLz��x�bjO>�V��yAb���CUܩ�k���}amC�ǵ�����(�KB.�5/9`?�O���%���܀c#�F���,BE3L،�r-ޓ�`����n����P��2���&��h+����6Ԓx
���]
q��^�)Jh������"���P�G��hUX�VV�+,
!m#���߄ظ�L�$�a�ѰQ{���?��9�y%�$��I�D�a<U=�S��|w=�LF=ŕw'�$S��{��	�D<!��
W������bD�����cha���^���;ܭ^��⡬ש��ªbp����ld"���˄2�DY�L�&50��3����ֿ?��c;.m�������������}�r���e��iD��E�SZ�	�Z��Ep�Hi@`�4l(B��:ԁbi��jfej9�j���
���s�������Hx��P����֣�,�#v-[A�ڑC�	aϘ�O�*F�O-z%"�R��=�$�_"�~&�/�T�Axgq�{_�$^"R����j��vW�����E��;�:�C)��U� S�P6 �^��h��ŹE�o�jr/#>�n!"/}�D�W���^UX�>�7�a^U1��"qN��?���{=/{���L鯾E	�{��J������ud

}�G�-_�u�^vVt����G��Ĕچ���}���.g)����m�9�#�4l�fx��H�̱�Lj&9��mvʁRJ:.���(v��^T�v�U�`�ϚQ-�Q���lxr�8��?��0���5sD�K��S����$!̹ġa�Y�+�Zl;�p�嬈�Y�z��ֆ���m�	O��3�r�dǋ=�*�wl�K���V�7�8b��<jf��b�6_�P|�Zļ��~i�����a!���C쵋�c�
�t:�~I�ft*�:$Ȳ_E�fؕ��Q���Mp�E1$��sԣ��5��(C'�q�� �w��no^�E�!�]�8 m^�<
^��\ڤ�;K��g��H�{���-A��e?��5�qtca�1a�F9}���b���1Dm�OU	n�\�� ��3��1�����l�H
��>��fƄK� TW�p?�~�(~�0fĽ�[l���,���Lz�����' ��MZ���l�N���lzǲ���>��,|/7��GJBC��TP	�v��4c�5��+;�m��P��p��Z���x	�W�)�\����+��4�X8ie~b�0z���+q�yg��L�}����9*��R;�T	=�ۛb��83#����w�x�� �J:����]j��9'R�2��_w����	���o[m��94��+����qI^5��MPo������	���Yއ�y��q�P��c���E-�c�{χE���+�r�N��j=�����)j�~T���\1��@�Im�P�{U�p�]�*A��G�NEf�JA�`�H�nͽ�b��!�m���7[g{+ꥵ��\Q7n}��N2s�6��K�xo9�{�X�o8�X�q�7w�42�<��	b�H܏&��Z*fFۖ�8�S���:�f6�f�
fL���w�8�J�_Z�[�ے��{�Lu��v4&�
�K��Q(y
�_��ݺ�K�"�XN�gf#����ܬ>�E�z�O�T�7�>t� ڦ7��t�}��4�I��1����+�b|�]����"�ovX�"�ή �h�ҵs]
�Q�8�q�5�M���Ե�X�j���r�;�8�
}
sM��ơz<��� ��V�-�K$��|e�褐S�9[zH���z����Gp�<�䓄����O�Ћ���k����m���=\/��Z��l� ����B�<���O��|�P����>�&�I�P��v��$�_�7�_2�_rӫ����O�/С�}czӋ������ZE��ƹ�_֋�SL>N���Iz�Ճ�~��uZ�1; ��oC+<f<�d��N%�z�S��L	�Ny�����{���*�����y<�w���G3s��|z��Ϫr^8?���'����#_�=����Ck�|���t*
72�<�**�# z-�A��V�C�*����a���A{��eP�f�b.�O�#BI���K�0�b�B��]��N�	tڭ�հ����4�
)
�X�2�?m�3a��+ʬ��؀l��@�FA��O	���؄���|�c�4�>}�q��Չ�Y%���4��\|?�R�Gr&�O��a}k[�ԙn3ՙ�\�����Q������k�����>�o}�v��L�6�Q�>�[WQR�55�ի;��E�[[�S�{\�Яs�f�Ug^�6 o���	x}�?���}�Ƨ��Cjx���N�o�f�N�z�����v����Ds��hȉL��5z����n�����zK��}
x|�`}�=��Ka�H�EʡFۘ�ʠ�{��]� ���E���s!�|�(q�XR�*X�ޒ�7����[W�ג�I��(�̅P9H@_~|J�U{*�Cyy.b,�dt�+x,i���[3�P��J�u����9��`�p�`!,o�	��[8�
�ح��Y�3܈�:���)j_����[%
("ʻ㭹��u��[�{��P���|�U7R<ߊКV��m��X�P\̖.uiQ�k�����\�9!w,A��r��Ժ�5K1ˍPF+=;�%"����r����a���m�ɡ �
CU�Y�.����`NT��kE���S�q+H�S��t�n�J���JA@^zs�
ZCT�G�i%�����ZM����"=�*��?��N��6�:���N�=�EU��Z�oP�k�)���y7PX^Kl-�N��u����M�ݟo�
nE1��>K]��:��/XA���;z��a���u&כ��QD Ǒ��)��}D[�?��"���9.jƜсb��J�(� YA�Si�!�D�r�|��˲������,���s��D���p%�*�$��3�.��0�YqއüӋ-�
�U��*�@�r��<Hn&y�'�}=/u�\2���<�"���*­Tjߙl�
х�B�T�o.�^�+�Y3����EЇW���X�
�7��
��ۥ�	�'�l�Ǹrgk\�s��q��2`�p�1�v���+���.�t��E݀���.�W�`���G9"�-����*YqG������h���U,ֻ>��p͟���D�s�fV�믣�w�(*�'�8�o��O������0��:��:���%��W�
Q��cڰ�SQ�!K�{|�?��]�1A2��:d8�O�E4�'Ǣ6� �x.���@b��[��o\�@�$�Ţ�>�v4�a	�k'��v�Ax���G]d �ӎ��Gam�m�ܦ���l��$���i��JL��2\bb��ۢ`C�9��JQ���i��%��f�yT�|�[�l*l�\b<{�ݎ���ƺQt
׈�ا��nI�a�Ǉ�q[��||� !�o�1@���B��(:������ZE4��r��0�*,��Ϟ��

�<�c�{8'ǳ�^ґ�.-�{�]���x6�M��9�����rQ�����%�ރ�����H�fs�|rG(H�y&O��^x���
l�W-��G��B��)�M%+�#I%�p��^��J}��e�Z�wE:���}���*�c�8�7L�ԋ6�\p|���2�%�{9����N�ϲb�ĩ�����5
+D��J���W������������L���Zɐ;(d���Kk;��k]6'�r��� D����C�6<�O�Yƥ١F'���c_�_��a�������{������j&s]����Z���W��%/�Ꞹ0	R�3�;�{��SѮ��-0ey��
�:����M���l�s<m8�j�Nס��N���@�;���hX�j�d�K��ĥY�$�CȲ���O[/�g�t�������
�O��0&W�����OK�p%��l=�4��&�v2�K)[�,~{��r#�&y)[onա���x�m)_�I�_ū��������4�fd#DW����`?�i�>�*Z$���+�s�ᆓV�.���ȥ@��jZ�TbJ���cĲ�YcÔ�6)�J���."(ڊe�{
�	�<��)�l8.~ũ��6܊�+���'7�
+��;��z�t��b���Q9��0nG�����m)�	�$e����랮_'�υ�7[)s:��s�T�w��lp)C1�w�'Z#��9��H�Ck]�Gv�uvP��`�l
{�c�;��N
��c�v!g��ǋ"�FG;�=����zo�~���Y�3R���1��_��~�J�G%ϽW%x�����o����M�ȅ��}�n�k}Iǒ��}�����-ub_�K�KG>������'�ڸ���J�
빡�k]��,����H�R�.Ydǭ��uF�����g�� �K������~��ϔ�{�/�����]���S�ZC�
֊�`+V��U�ݡ�ş��mDW��o7�.�����Jf���.�D�n�T'*=�׵����1Fo$��]�O�.���Vz�����`�ܖ
�����1�i(���2�D28�
����S�����:�y|gT�=y�L���iAB}��Dh�u��i��چ'�K��#:�v�?wqn�����hj�������p{'�>,[2+Pʵ���"Eٍ)E�-���:<�	�-���e2�w������eN����/t�с]��ꔹGv��W�wq<�
ƴ(����.�,�1c�a�^�I�ż�����/��_~�MJ��EB�v�:T�E����v/��j��X3P����1Fk��%5��<sv��v���ϙ�S���sEg��u���|�S�Et
��
�D�4���$��ė�z�]�@I�����2�kQs���:��L�ϐjMS)�4pC&�/�g�!�D%���(�,�8�+�_��F�p�K?�nW�_i�v�<�z�X�V�Y.�<`�ּ����cs��0E��a���z�=��:D�nZ�i��K�̷�w����%Z�~]zE���ta�mע�y��?.��!�C�Ìgy�R�|�+��yi�s���?��Ox)$��x�����c��g�j�,�;?_� ��5����y��1F�eA��f󀚓�r<3�?e�?i�QAI�}�e�iNNʊZ	9�F���ח��X��A�Ď�'� �����7���;��5�#J��wuY���N�ͼ�#�\�pD\Ni;5�H��~�*
�P�;�8��a�b�sE�������ƺ�^�M�{�@����eSg���'��;��N�>��;[`��37ۣ���?���3�ƅ�g�:T��~��#xoŉ#��K��c�����͓w�)�hk<zZ�K�����MB3�52H=ڹKI�*u-0�i��ѩk�7w_f�ݓ�p?+�uސ���7�%�h����_�(������UF|�f �f�����z^����������N΢�A�n�<�Q-�<
��Nz���侚{��"S��hGqy�ƽ�Eb�����o�ʱl8J�hc(�X\#�ة����!��%�1s���J�t�V�ŭ�!��`�`{̗���=o�� ��@%S���A��3j��L%2<���E=K�j�9�N���!��D�w�9X�@��Y����4Jr����1wz�w��m�)
Q��Z&~���Nڍ�P���C2!6�J�J�����
�z�ً�t�xK�X�B��#.����1D*J�ퟵҢ��kSj��D�$�SUn4��J�B�g,������JM1�sVK�y�ɼ̿�
��Y����eh�Th�t��m�唊�p��{S����e���󩭸.��!��p�kFq'y��V�М��KY]&���� U��K,�]+I�V����L�1�t�SV���Ƙh��g��T�؛��%��&�L������z��n����m�o�;�ĭaV�qwb�)J�vk)YR��m+-J��A@�E���Ws�r��ۧ�;K�H�����đ�a�U:��ӫpK(
I�y����]/�B
���8"�GdK���,�6��
A�%Id�����U.R��Ð �'�!�"�Β�����u����k5ɵڙI��S�<N0�ɇ�)�Ďw�o�zb4[�-	�VUvK'�cK��u㱝?�
So�l�N�ȿ�㣉9�^4�l鳖��^�u�l�0���{��w�U�oו����,z\4��K}�E�[��aYIj��P�*�"Y"i�q5L X��*��V^V5��o��a�^<�Σ���2��7e�-��2̽��|��1�w��.��$�K�1�R�o����[�����ml�/�v{����"��[R�ߪ�����o�\���j�1yq 7�&+ۃ�仏�g�XG0Tl؞����Q�����w}=��{pH3��>
�[�m���w�Uzu����R�(l���&i��xl]t��K�[�n@m�t�z�e~'�(��}��Ė��o�K<�������!��r��q�a��v9��]G)R�<��M,զg�^u�����9׃����t�J�t�"\LNۚ�{����J��i�����u�FI2�$������ofz=">�Kx�e�p"���a�wc�	�� �O�)��+��􈺏��	���w�p+�x܇���{x����TN<r�z_����w���}eu�f?��v�P��_���|�P��_>�:ظ���	R����D\-D!��J�������߶&�
�@�u�5�����f����5��n�7hz'�vp]�^�����x��R�r��t@�2� htV�AF9R�?�b�4�/�׵O�z�vc{mF��	.W�0�O)��������e�
�IUܟF��p��[1��EW�;U_��� �Ѯ��'�$i�s+��_��L��UD�/� �`�{<�,#�҄�}z�em̢�]E8w��J�;�
q?X|����G[�/l7�����=����n)���d�aOH���`	����H�O�PӠj]L���KeV��H�
��:͗|��׳���ӗz1Oߎ���j�Mq�|�R�@[R}�~$��e�\Zz=��1=!`2��������}/���P�<��}������M8.��\�U�ש\�gi���7���g}��7�m}��W>F(W�S~��}��,݈1�"���������"�>������ŭQ����|߇�89�*�������ה{0M��y=�>R�-'�D��5��'�8���}��|�G�{=���}Y���j�FG\��ۧr%�*̩aH'����W�U�F{|J���w-qu�ƫ7�ӹ��QB�����M�F��2���:m�U�F;�e~��e�ue���Q�韛$R"v�u����A?����n��RF�����G}<x��`��7cCn��%�+��n�&b���-��/n�;��p�Ue�NY��������U>�#'���$��7���av��C)a{�_{��0i_���=컙P��� �;�#3�����u�� B��V!��HZKF8NN��*rk�A�C�g
a�EVw���ܤ��/�n_�a��?�xa��s���?�޵��Y�Ƌ��{���&���{���x8+ ��{���n�ݞ��,z9]�e�7��@�@��»�ݞ���n�>�t��'����A<H�ф#O�� C���"�`��7��rb
�����5���D����(�X<q����%r�̤X��ݱ=}�!�H���"��+�?�n}4�����{{q��Oytԧ/uX�����h]��2�~��;�#Љm垨&й��H�L�t��n��*�O�7�_E�r��)�W�x�5���=+�$���H��"ŕ��8�Z@-���hL��dAj�-�2�|����d��4�;>j��:�2C� n����^D�2 nP
%�{�]��24
�������2�r#(Ľa���D�L�H��kκ��c�Q�s�Q�K���\��
���+�@+-�����ܓeM�3�?�}TX�䯃|;&,^3��WH��L��\��jx"��)�_W1\#
�φYEct���	��NV=�(�#�~_�-w ��g�s 8�N��!�e0Y��G��2��/� �P�>I���[8�b�Z�x'ދWUP$�b����$p�.�m�!k�bk���\!����Pz��[��#3�%���exd"�8�1���~Y�0��Gs�G�Rs4���x�A;���0o;�ȀW%���A��|��s<���g������W�/jZ��$�3�����;�8ZV�Z1��wQ���w%u�o��_��.�mqA$�Ź�`���VX��/�5aKx�,���@�`�/}��>�
1،郦�И��w�5�Z"�H��W�F݈�K&�x~�.��+��Ĉ�x��VT^�����ˮI��j�q�=���"���NI�l/�i%�E���}��Xn��ݗ/U'�W��'y���$=J��xn�t{��7�S�TF�F_ˍP6��#e�S�W!x��ny���7u��?5ܨxmЫh����n�y)��>�&J�Uy�	��g��uc�85����J?tO=�*����ŵ�r�`d�0A7�omL�v�0�[���ٶË�?�&�7���~
�s��p�X+�?I�Z��^��_�[����.Ϗ�>��t�g3�#K��:����a&3������þ���İf �|d�7k^��%<��qz��#�7��cl��^ϓ'�mקw�:t�=��z'���-���a�뉍����Qo)í��-"���
��i�w������wɊ�Z���_33��!>�}��

gh�7�:E��Jk)>O�d�G#
���f4�`��[vU;�W#������������L)C��D(v4K��7�W�]D�%���A�j Z��?�3��A��ﯚ�[@�^�˾���H���E��>�- Y1���z�{!PI���4Є=����|�
C�s�t�S�c,��Ø)E}�	�J��lE�4M��+��+\Y���%W��J������\]4#����IH���D�U
fC�vs&����dE�2I>��������"w�X�����$*E���<P���"w�)��da�_f��t�V���y��z������k�=�j��]rܿ��5���s�B���ޡ���nD�:��2hF�G��Rfg �w-���6u�+4;��7�ݨv�b�'����
��u�hD���rc�+@'g�@�\h��湆�li�u�s���֨�<W��z�i�>���i�;-�0ů�1�k���ݴ4��v����&bz���
��_�l�Eaڰ�F�H8�����m�l�����cۭ����{��/�)�����{�e{��k0/���E�d��lyW����a��)L-6��WT��)Q�
qk�ŀ�3�
(ѹ�s�qDgٽ`��ְ��Z�$Ѫ��� �[��2'�b2��-�3�����}醆`�x����b�[~��?����Lt��HOQ7�Q�Qb�M�2�b��=�c�3���N:����P�{DL��a��v�����^Ov�'�*�0����<DU�1�m/��B�K�����R��
S�$���%c���Z�{�4I[�P�Ru��`�zj�[��ps�E$��z���D�
Z�	����lhK˖�"j�Z�ǡ- �"�N�}V�j�*��|��7���@1CX��kK����.aP���O?�ɼxh[hG�Z�mmaB��u�D����O�"ٲ�e��5}�u(3�Y,w)��+�����dK(�a��n�}gQ��Ŀ�C�S�Y��
2�6?)?���y��#|���5��Cl<{%*�u�o��x�1�-G7����;1�����p����Q�.�uLpk}�;��Z=�#�7���R�������'*�u�k�qT�֣#Y	�7>+%�l숔���Y�M�-�����sE�NrQ���u7��f���j3���Tqf�Y�|
�?�+������M+�����l��1�l0j�+T_�1��KL|L3/�ſ4v�����������{'��Z$U6�uw{Fu�[?�����$&�&���&�[���� ¿k�4Q���`��Xn>kY�|C>r+)��n;QL�'�+@��Է�O��{_y����A��������3�)$�D���A���:A�J��7�w<P�d�r����8V�f��K
Xe��W,�Q����%��?؟�&� Eq�Ma;���cV0�w�p�V��尛�c9����o,k�1F�h�E��JO�F��nopR�\�?��eZ����8�{����q�J�b�d�Ѡ뢷�R��E���myY?��o�-Ǌ#��R�����EϪ9B��Q��'a�
��Ȗ$�3�iƕ,~gm�9t��޾geX6�V���?\9Ö�����N�7Φ�4�)�3f�1�<��������K��8w�Ӿ��E�=m�Ы6̳n)���z�q�q'-x,k@�� wj&��0�f�w�5����{8�}�������J�V*0]�"̙Ӿ.b:m�&x���No��`��Zb|�Q�c�(Q[�E�
��$����v�������({
���6�=M�ϳ ̯ۀ_gE+̱BF�Al���^*%z���=D)j��nL��a8BF�H$� ��Q�G��(%�N++�8�4�d�tU*nn�2��0�Fb�Jh�*%!/��)�FzQ`�J�"�@�F�Z��&K/%���H�x�x��В"I�#��G.-%�����FLVԢ��R$�bB1�;�f������$�3��	rK�P�O�`�a8D�$�� �Y�?�����*�C��qH	��VA��S%����] ��y>Q��K����$�����Y� yh��g�E+I]8�0HJH
H�@�t���@��H7��L�"���E�?��,�TJR�	M$t�P�aC�J����v]�����@S<$�|���4%��C�#Г���G!4���u`i
:�#��j�b$ݸ����i���4ʷB�i���>�}��Y8c.����>��0�����=����w��4q_ ?�!U��vˑ���s�����>j��JY}�����ӿ�������-�������( ��S�?��S�?���T2�S�?��%��V��z֟���K��۟���[�t؟�������?}�O_��U��O��S�?u���%�?��S�?��S�?���T2�S�?��%��V��z֟���K��۟���[�t؟�������?}�O_��U��O��S�?u�=ȗ��O���O����OS���O��4ϟ���
Z�O��Y��O/��n��Oo��azߟN������?}�OW��?}�O���Ot�/)�)̟��)֟��)ݟ���џr�i�?-���ʟ6�ӳ��ş^����ϟ������?������K�ʟ���u�ޟ:��۟���n$ſ��?J��|6��b��z�����K�A�B��{���qȍJQ,�^De�u�;��B���h1z��ih,JEi(�C��4MBZT�����eԂ���BO��m@��FT�֢"��֣�q�bѓh%Z�6�b��-Ck�j��F�1h	��F�t�����0yx��l螿�/�yt�E�OЧ�/��}����O���o���P�����=�n�_=��
��	�h]���+��~Ѻ�U�B�~ �a���+�^�n�ld,����u�Q�6u�v\�X��`��"Պ�k
�4 �$I�2߬!	$�E�RKPK�E�bDHDJ��2�@��9E���'>��/ZU�d�v6�
qu��c����:� ����e�l�����&ܯ�=�� .ʇAj?��)-PKA�+�Q�P�P:����5����Sp�N ��=���I�?�,����7�|+�����)&�>���X���|��-[_x�b��/���W*w�ڽ��ת����3V{��q���T&P
z���{�G�k�I?+D�?A:�QF$�0�_/�����f���eB=��=p~l�&�����^�`����')�<ESB��y��"$�W)��?���!K��H	�y�`^N=�������<��P>�|��Ѓ(�y��=pσ��߿w�`�~(/�����%�y)�`^F?�O�������>���:`�p��00OB��0���| /���O<�?a���e����+�z(�P�����b��<�#'�@!�H1��$�7l����`4EC�ߢ� X0�g�Ӂ(�p(�<ǃ�
��L��E`�P��|���p\v��������{�2� `-�s�[&m�٥|f����ou�};��Eұp�[�ཇQOއX^�I���W�4H�!�����}�j݆���u����e���֞�G|9�_���Z��|��_#i��~�A�kG�f<���Aڱ�i���O�8)Co0f2B����e�W$ůٸjU���꡿�5��)ܰ	�=��(��77{\��B�����}g�+�s�Y��I^8[����g[�r���	����Y�� �e��m�|~sw�j8�n�Ӿ	�������G�Y�0 �c¦�t�e��k@�}b��C4m����o
WL;>55}\��I�F���8v��qr���צk��&N;~tZڸIc'��Oõ��v�x�v�x��u����_�쿠�@�I��'�=����k\��o��uk�n����G����?M̘e�k�,���O���
T�m,��~9�ցoP���Ƶ�Mk7��.\Ϫ6�U	b����V�vC��ժ�����_�B�x��O�+ ہ��S�}z�j]�����7=�&A�ڴF@�<}�*v�U�/��/��X�*A�~UAA�*u�j������ҍE��%6l�0�ԪRUc33����>��0�p���0*��2 �)��?�F@_P\�a@�P��]�R��׬�`�jS�z��u*@��C��_.��C�����������o��cǍ7.m�6�?
��7�Y�f��j��_�o\���@��:��oO�t|z���V��W�OW��~3���NX��/W�|B��R��p͆��mTϪ�X^?�)��q�#Ɗ����g�Y��}|`�����~�9@	a�\^��j�*�2�����zl
����e�P�W� �d��yb���j �����~�Uʪ
��N�k?���U��-}|�UE��i�1��$�i/xJ5��W<�q}���+�MS����+X�^;N-/X���'�jG4� �BxZ���v�&��l0��_���h��p�j��5k0C���9�b�U�W��p�F���c��g��Z:7o�C�b�cϩU	��=�B����z�O�=sVޜy���i4���Y�*�_]@��i��M��t��U��T��c�O�jY��ka0'xb���o�Wm,�-!�]]�jU����kV����Dk

V�6l\���;Y���oZ��`5�N�]-���W�
|y�|P�0oR�Ē�s������I�[�3pp�V���>�3B���7�}-W,[Z��|%���1��_C�e���_:^v�1ׯ��M��
�=�67T�9UJ>\��F����sx���us�r���5�_��B��K|Y_��0��ܐ7��y�s�i�+@a����cX�������TSU�ڄ��%�o����_(	4����#���������IMӦ����_z�����[�R'���  ���m�h��q�0_i?��K��?X�ɡ��_l�o��?E��+�y���:V�������;�J2sr�;zDx'�����喩����D4�#�p$Fx?�}���-�gi?�v����>G��Ā3����&}���n'���S��y`;�?���������fA�/�`ڃ��~�,��v���o�N{�����I��D?�����p�~���}oE�㿹76�����,�s���ϫЃ��fC;�A���w���_�����}r6fU���cV�HYU�fcqJ���)��G�_;:��.�_�f<:�[3��F����y\�w�k�<vKJ�dSk�.~�hˆ>��O/n,��!�	�R������௫�3>�;`�m�c�_�/�g�B�������_(_����>�ʳ�|�/��B��_(o�:'��rH?�&��r,f�Q���DK���Z�r�rv����W!�^��h�rp��6�C�k�oX�/����U׳(��Uh�����ڢ�5P��|�����KaM���psdq��X��/\��^�l?X��DE3r���������RG�CK���\
+��'
�o(X7o�a����/[��?�z�?ڥ>П�I9��pݗ#�t_��
amy�_�1�P�!�@�w��i�O���r��\�{��/����%`�c@���Q����sʕ�����_.y�(�ʺe@�@�X1�\4��r@�@�Z=�\2����������7xt@�b@����7(P~n@y�@??�<��a������������������Y��K�v�.������
������V
yB����?ݟ��|}��o��EB~g^,�K��!�T^*����2!?�?/��� !?�?��1}y����>~@~�C���3�O{(?�|�C������~(?衼�|Oʃ�;�c��f�Mֶf�_�f��}Y�8p<��A?��4���|�tTB�^
.���$~�`�#)>ѐyA#,x���� �� ?�>%�fm�N�kz�i��">Ͳ�n[��^��]}�1}�i{��|c����i��eֶY;�=�[{��[+`�>��<��}�����_̇v;D�=�������[���Y)B�2����k �o�����+�v�q�B�����oD
ٿ"����6Q  �!����n�U��>N�"ip=Y`JO�Х� �a�"��1��d�ϣY���ү}�W|��PzJ��^�ڠ�J���:v���e�ڑy|�G,�2��%�}���B�F�L��"i��!�":�h�V>/|c�^���
��D��v{��
(���z��غ3=;O܉f'�������N�\x���]�l�a���,���h`j�)�E*��l�����<ٹ��m�Fl����\�¶���Y�w1QI���K��W��?�����R��
�J��";߮�#e~�V���v��S�S���p���Qv�[�ݏ��{��9���E>����h���Z���Ж�k�=b8ٳ�N��0����{���7��~�����b�_����u���n�s��;�r���_	�A�NDp����_p���$�li���
(��
(��'�����2q���	{�`���B=r#7�5�Ƕ��^3~��v�t�ݏj&	��&1>g~~�=_��}����^�N�������}X|�Z��~���A��sk��?�����Q)�/H������#�~����)]��_����W���_[��� �_�������I�C�� |^j���������D��sUé�=ɝ�Ԏt_�^��I%S�^���~g���Ľx��w��[�S�x�۾���]{�n�����v�ţn{��mn���׸�ۋ��n�t�
�E�
��O9�(�}���$��-�v��b2��-=��B6OL8l-�-����9G��Ӳ����Z�\X��^H��zS�L����YVn9�����C�,�9��WY����Z�kłfV
�\�(�8��t��hv��H6��
�}$������O�g^}�����һ�z��&{v���v����y�=�s��?yg���������ξ����gA��Ѱ��l��K�'PO*�M�󺅆+9�^4������1�'�ICw�����Qϳ����[ �g���#�,:�������|�@�^(ێU��:�qm�(t�Z0��2����Q �pK:"�x62�������n�V���\����h��'�K(��&�]�h��!1�Hf h�Ăsd��^���}�R��i��.dZDH�=���ON��.�JΩGMb6�vʕ��L6&ۺQ���vg[���y��͝��!�F#��4̗r�M�/�����|�V�s�!;c�Um��s����ɼ���q��Zt�k)o�e����-�q�|����U(��m���[�sz�\J`�m�|ZCj�,a����38kx�`��V��e#_�b��5O3Y��p�z1�`m�^�j`�0��}��v�u���xs�h1o8�FF�(ܐ+ܴ(Hj�j�II:&M�I1�c�nՋX���Jt����)|�pB���8i�h;ۡO|i'���4���U�8A�
�HW$ğ�~�'����k�$�#Nh����#5G5�%���L�=��� >��O���1<U��i�[������̫���#���������O��ou'�}{���&���o>q��������)��r�O�������q���gA�����o(���|��i���5�����%�/1�pq%n�h�ֺ�F�k.��n!�F�k��4���5/�ݮyQ�v
���v~FK�������:9�
�k�:U���a�jd}��܎䋚�i=o��U�k ?-��s?��/)pK�? �~3$���RB�L!�[
�;
�@~{Dh���̏�O�
�
��ၸ���^�~lG�p�@�� c��q�@�x�nٗNa����!t/=�炰C=� ���Y��/k�:$��9��+&�߮��]�V���C�K
9�D���A�u��B�7��� g���g
��I8�w���w�����ߐp>n�����ޕ�I��I8>��|������$��
��{�G������ �O
����"ݿ�;���ZC��,�k���o�ˏ����Y$;������uR��7�>%��m��V���B���ߔ���?U�o����'������E�?�·8>�o?�E��σ
�7�fqP�K���)��X!�/�/*��:�__'��A�?��"�s����om��O�ś.��u���#�q��y�		�����
(��
(��
(��
(��
(��
(��
(��
(�F�?+n� � 