#!/bin/sh
# This script was generated using Makeself 2.4.5
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="2352760090"
MD5="a0792308cfeb6f122a6a0954a10cabd5"
SHA="0000000000000000000000000000000000000000000000000000000000000000"
SIGNATURE=""
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"
export USER_PWD
ARCHIVE_DIR=`dirname "$0"`
export ARCHIVE_DIR

label="DevTerm Keyboard Firmware"
script="./flash.sh"
scriptargs=""
cleanup_script=""
licensetxt=""
helpheader=''
targetdir="tmp.ilS2Zjp0w9"
filesizes="37836"
totalsize="37836"
keep="n"
nooverwrite="n"
quiet="n"
accept="n"
nodiskspace="n"
export_conf="n"
decrypt_cmd=""
skip="715"

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
  PAGER=${PAGER:=more}
  if test x"$licensetxt" != x; then
    PAGER_PATH=`exec <&- 2>&-; which $PAGER || command -v $PAGER || type $PAGER`
    if test -x "$PAGER_PATH"; then
      echo "$licensetxt" | $PAGER
    else
      echo "$licensetxt"
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
${helpheader}Makeself version 2.4.5
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive
  $0 --verify-sig key Verify signature agains a provided key id

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

MS_Verify_Sig()
{
    GPG_PATH=`exec <&- 2>&-; which gpg || command -v gpg || type gpg`
    MKTEMP_PATH=`exec <&- 2>&-; which mktemp || command -v mktemp || type mktemp`
    test -x "$GPG_PATH" || GPG_PATH=`exec <&- 2>&-; which gpg || command -v gpg || type gpg`
    test -x "$MKTEMP_PATH" || MKTEMP_PATH=`exec <&- 2>&-; which mktemp || command -v mktemp || type mktemp`
	offset=`head -n "$skip" "$1" | wc -c | tr -d " "`
    temp_sig=`mktemp -t XXXXX`
    echo $SIGNATURE | base64 --decode > "$temp_sig"
    gpg_output=`MS_dd "$1" $offset $totalsize | LC_ALL=C "$GPG_PATH" --verify "$temp_sig" - 2>&1`
    gpg_res=$?
    rm -f "$temp_sig"
    if test $gpg_res -eq 0 && test `echo $gpg_output | grep -c Good` -eq 1; then
        if test `echo $gpg_output | grep -c $sig_key` -eq 1; then
            test x"$quiet" = xn && echo "GPG signature is good" >&2
        else
            echo "GPG Signature key does not match" >&2
            exit 2
        fi
    else
        test x"$quiet" = xn && echo "GPG signature failed to verify" >&2
        exit 2
    fi
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
		tar $1vf -  2>&1 || { echo " ... Extraction failed." >&2; kill -15 $$; }
    else
		tar $1f -  2>&1 || { echo Extraction failed. >&2; kill -15 $$; }
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
noprogress=y
nox11=y
copy=none
ownership=n
verbose=n
cleanup=y
cleanupargs=
sig_key=

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
	echo Uncompressed size: 100 KB
	echo Compression: gzip
	if test x"n" != x""; then
	    echo Encryption: n
	fi
	echo Date of packaging: Mon Jan  2 20:43:06 CST 2023
	echo Built with Makeself version 2.4.5
	echo Build command was: "/usr/bin/makeself \\
    \"--noprogress\" \\
    \"--nox11\" \\
    \"/tmp/tmp.ilS2Zjp0w9\" \\
    \"bin/yatli_custom_keyboard_fw_v5.sh\" \\
    \"DevTerm Keyboard Firmware\" \\
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
	echo archdirname=\"tmp.ilS2Zjp0w9\"
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
    shift 2 || { MS_Help; exit 1; }
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
    --verify-sig)
    sig_key="$2"
    shift 2 || { MS_Help; exit 1; }
    MS_Verify_Sig "$0"
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
    shift 2 || { MS_Help; exit 1; }
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
    shift 2 || { MS_Help; exit 1; }
	;;
    --cleanup-args)
    cleanupargs="$2"
    shift 2 || { MS_Help; exit 1; }
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
	MS_Printf "About to extract 100 KB in $tmpdir ... Proceed ? [Y/n] "
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
        if test "$leftspace" -lt 100; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (100 KB)" >&2
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
� ZѲc�\t�u~3��eI�ֶl+�Gc#@6h��֖12��,;�/� (���HZ���+�����m	u�U+`Hm�@�Li�C�s�+ Ms�:8!.���T`�s����}3��y�#�Lz��g���{�}?�Λ7ol/٤lW[�>}n��UN'��+,Վ��U��Y�ҹr�ceyr���9*��@���
�� �ң�}�I�](��%A��55k��u���o�g��mm��JY[�����P<�A5��KX��ʺ�X#]awK�EXjy֌¢���R�[*H�.���t�˳�⪯u$B)I1]�V&��S�����-+��W����Oy��oW���}���������|��/���~/�y�]��m��⩈�'�������/�giY��O�����R������g��厲)��T��`G�ޯ*-��֩����7�U�n��wx���g���(���Krdu�T�C����˺�H�  �.���Z}J�]
��R(�Q^����R��/�;���C�ƦM�e%���Ssccy��n�vfea�D�he�E��T�TªGj�B�Ou���6M?)�C�4Z�2�[�0Π��B�P��,%��>$����� $:���2�
	"Ɣ����Gm�;�v�M��g�{�7�]U;/��cw1�L�����]�����+M����b��eg����%9�^�q�(	ނ�an+	�.��cj�B���]���L>���43Q�.�Z�y�.DF*0t�$��k�T�b[3;Fj��m��H��\>�O)"�RJ�g%g�yZ���J��h؃����y����R���\Ƨ�w��<�v9O쥔�C���R��6졀�T�)��q�曐�˞��3K�b���Z�����_Ye%6$ә���>�aA�(sF:|>B�Qc=�s���6�O�)��qhX��g�G6��j�w��sL�&|�	~֤^���4�&z.7�&����Ğ�&�ט�Ʃ��U�SA$����ew�v�U�����Qgf��(�;��7������Ӡ����jGJ8�Cn_ ��@����d�ew�"�z���{�
,.X֦�r����{�ްJ����F���5��K	zP���5r�����6�0Vۼ��l�T���&�Ňu�u��LYϚ6c"d����~��I`�� �Y�/�=��s�k�_�Wi\���D:�'��e�8��6��}D���~��Q.)W2��)�/X��������>��#����<����V=��c5�[Y�`p֞�>���2x&�ocp64638���������9l|b����l����66^28w08��>��|�e��>��_��[P����xap�"���+�!���P}����>I,x�@����Zڣ������a�� /�M��~�?|5��#�-���1�����.��O���E\��I�'�|��.���������U\>ÿ����Ũ��%pF-�a�+6r9�{ڵ�����@����� ����4�7pj�g�cp?���x|nܾ����B}��.zBg����ѥ���)���Ex
A�X�Ͽ��/��맪rv�u|��3K?�ڏ����O�c-�����qB�e��~��\��%���}c�1�?�ʰ�b� �O�)�ކ�jt�{ٮ������&ԁ�)-3� �1|-��>d"ˊ'��k�������M����c��H.�i6���	��@@{_��zr]� �[�
�F�1Vo��*ڴ���JI�Pgqߕ��Db� �E,�[�-�\9�%�G}�r\G�tdYNPh5P�Ȳ|WL�G���]Ǆ���p��B��� �;VD�ѱx��>\�b���<�g����mw3�7G�So�tBwE������~I>�VZ{�T�b�7�jd9c�6�1�t%�X��;����q�n@=�~X������������+���/�S����>��?�m�l������@z�*�NK�"W�c����݋�`>�~a��H��fK�o�~\W���Ժ���u}����gː���I�Z��uɤu���%k����GS��{� �)�|�@󕻾�m��9����Z��&t�tb���a2����� usM��]8���$>�=��<��4��I��I��$���0�&��Ǐ���a`Z�{!�-\'b�c؍�r�v����Zo��-��ɔ�gZ�^R�[�;���_�p�bD�����#߂�.s����~�!���m9���y����#�����?l|����K�S��7lY�T�2E3������3K�����|p[����5G�w�x��{Jq|�c��l�D2�Ҹ(�y)��������6l��T_ׄ��^�Ԑ6?�|n�n
)m�ᥒTR�^���n�z�rKg��k�O鑽~����yC�;�������Һ�uX�:x�P��m�� �$]�r
-��g{<�����=x� �K}�]���З���|���3!��8/��x|=���x�h�D<~?������f=)��{��{��0�@����s>w0����`tmG"�o/�U����C�����7�8�M��@�o��Av^�Νp�x�.k;(����,��w�"Fl���yp֡�b���?��P�����`ơi=���p:?6O�_@[ل��b���{�� }�.�:�yhz����i5߲>d�{X< 4��ƯO���S��E�h+�T�'�1`�lS����c�:���c�:�h��ztv��F�$��}��Lt�s�L�ĭ{���tM�2d\�^ĥ0h��]����%]~��ӵ�yB��"�xOyF��k�D��Yӵ�t�w�o�0ڝI�gp�/���� iW� |�'<���?$#|�%'Ҍ?J�?�ȇ
����9�{����5R�M-]�p�t����(.�����?/s���:|Q�a���|#.&ރq�N�[~`ħ%ƿ�H����?F<31�����6�Y	?����9�~3�3�,���D1�蹴�-�?���N�R� �KF|n"��~>/?�x�{v_�li��粢w�<~+�����$
��y+�|��&����9=�j�(���������K�����L���\&Ln� g��n?�_E�i�m~".�c�o�6���ӿ�AO긒����_�۲�ٓ:n�Vӓ���g��9�������W>�o���sz^"�%�Wr�r{v��9dCi���������DO�\#���s�DO�܋�4����'G&~��j��}<��'[��ߍ��*OL?~�u�|�\C�<�ŷ+��3O��[E\���}���f1�~��	�Wb��0�����E\�4��C�!�v\L�鴉=�]3��]���)�7��U���qr����,��\m�o����#���~��v���g$�Lc~���]&�~�	��>+K�}V�0�3�����I~}��������>������E$?�';	�!�I����k���;��ǧ��K�6�\gM_��Lp�Uo^������o��I�t���&�6�������S�\[b�'���cyH������Ѓ
�?s���݊�'ߣ*��V��Q����]��v7J�S���o@!Y��6_��0�!Y��F�@G�O����e��g»뼲*=��{PkP�PeOWGG�0�9Æ���n��A�,���[H��c{����,�k��T'�m��e�h��Ar��6m�1�h�� ��|�\��(Z_ۀ���[��6�[֭k�k����7��t��;ԥՒn8t����F4�v��P(�P۴��n��*2��	�G	+���.

��5�Dn+�!U�;ԓV�_ަ��4�i�1 xo&W�q?$��ҐY۞ɉ{B�]�{�1�M��d\Oڞ��n��/w�Tۗx@ ���!H���ljP�o9�L��%��|[���� �mb5 ���+-@�A���+W�����U;x������{=���PVڐ�֮�ڑ���}:����`��҂�O��U�/�����p�_m�ۃm���v���`��%t�%�5(V:�n(5 �t�����b�g����<���O���nH������(L��U�<}�T��<��}��}���u�i�z=6��E�[��HL�OZy��3�En=��y���wY��t=�R;g?�y�N�)O�}(u���b���K�T��?�B�����C䫹�TJ0�����J~�®?S�w���'ϯ+:��q�����=J�q�e|�=���y� �|gf� �t�J�i4y������5f�?��'&��v��?��}���@���)}�,�Z�����?��&��L�oB���B&��ä�������@�oq��/)}���9K�D�����o�����|~��ʯ0��,M��\D�|V����4�;���c��:=f�<��6�����\�������� �l������e��eN����������O���SDEژ��& ��A��X�Ӝ�3 m1�����a�z����d��oq�pj����E%!���o��OA;�DޗZ�͟΍AY��F0�;�\|��Y+��$�g~.>E�#q)���W��g-��4�-e��� �	3ɖ��0�s�Fb��_v���I��E�~�~;���-�m����V~�����-�>xd��2�aWo���Ȇ���'i���<��r�{���>o�잼���g߮�z�m;7;��G�˽���S���6�-Zj߼�î���)��;P8~��|>�gs�����;9~��p�*�_��%�������?��/�@����au5�K�/�띉e�F��6Q�c� ����0����,�x�$%LAq!�0q)���)��S��1�`P�)��\��=�S���ⷫ:��{|�)�Z#���"F2ϝ��!���<8b��ޑ���G鵏��0׷3�M��F準��d����5�u!s����c�s�k+�>:0�"�V���Δ���GmC��֡�h:�q��W<~�8��ж��x�t8jq<����etI�D�E<�N'���|�p4�!�8��l���on�d�	������h��mU���Ï슼`;zA9�K������z��G�V�us�8
���؅��m=�͑"�ϱ?Z(��F-h`� �������at��m ;.�ȯ?�id=ʎ� �-�>��B�I� /���z�
l?}�*��Й��P_\�#X�10��/���!�k��Kd`8��EO��t::�ޱՎ�Q�t��x���Վ�(�Q	t/)K$��%MY�,��n�m�-M^p�w�]F�O�4���6��ѵ���>���>�I�M�ә!��m�eO8n>@l�[��6*alw�l'���tL����6�\H�ʄ��:v�fB���wt�%��dtW����"�m#���B��5A���������H�����z���㭉�z�9q�zԒzlc�	�Ȅ1�cˎ�r�	lx_[t�^{�M�~R�s�v�>TF���2F���j��@�=
z~��}��݄��ϐ��e�꣛���9�#��@���iB�P��V��Λ�۔T[E�|i��|D(Z��c���~ ���SD}M��g�P�
�μ"����V@h��n�m��}r��&���5��v����Ͼ������%���7���ch��2�N�πL�N�zb����%��jf�k��N'�O\��.?����g�>T�n5����|x�G���������վx�������{���l>�t���g:9di�[6�g�M_ƀ=�����ȀǠ��eYr�#;Ŀs$�'�]dh��o~��
k^2?����"G�n�H�+�;E#}���]"a@ބя�??~��Y̧�����넘AƝ.N٫�=������$ ?)���a�S��j"����p ��+�ҡa<n�,G��ݫ�{�1H��J4�E�$R~��aw�}rN�$��7����q�������`H�+]�,�(�WCV E:'m��"}�¡lrN_J~la�ʃ��4��Xj,3'��x��������7x����t����g����a^9d#����B"╓�7ü����\k��s)�+��N&�ǅ���
z���(�6!�K��Jb�W���yew�e�W�u������0?.����[]�Wzca�W~��0?!���xMF��qYU�A��6��|�U�<dD�2*?1�?:���#��{��#�]��M*�
�{Q�oS��6���	��#诊�OP�_A~����*>d��({�U��*>$��O���<�[��<̇��P�c{ҾJ���Oǂqh�	N������0ү����0O��U՟Ht�Ƒ�ډ�5 ���D%� �d�sW0�ؓ����jM�?+��h#�I��E�OF�o�"���"��b"�Kb"�]���>|}�h����:6R�Uh��RT���a�����p�Ԏ�y�<#�ǰ�?�Eg�p��?>Ǒ�-��x�!��T�̢���*>�OOpe�y��~O�w�o�	y>G�3��.�?̉�/���a	�{�R�E"�Xj*~����}?	<J(|�#J~MT}�Q|}��R��ɠ=��򏪞���GJ�!��Q�}T�y����������n���@���FZ��R�?�*�O+������|�CV��=j8��5Q�.:R���l�FZ?w�{^�O�?��^z8~����F埈�#�n�F���YY*���*x^������~�n�iV�?%����}'�]4b*3
4w
/3GB*�85.����ʼ���
˼>�����D��2#�m7��Eb�2G���̌F�e����E��2�A~�#�3�;�-�_���!maD���e�w�m���PG<QQ�����İ)�`�������jʻ�H|Y����#{.���<��{F�b����0�J���=Z��b+�+êw�j,ٻ%��;�9Ԙ1��{3��WcĨ(l��u����0`1�2dH0�\�s�&(��J���a�Br�U�(2�9�~[�Q���)�nX�(�ի�Ȝ�~�^�o�J��u�w��������5C"�A��9��(�P􍊒s���5�q�8�P�w*����z9B'T�(�fM����I�������X*X�h}j,Y��F��EfIy�6�����Q�$"g��τ�)�¯��E�߾V�`�,�2�R��hL�%X$F_�/{t|�e�ݱF?~��>��Y�=�j�ekJזÔ��2���3տ����$/��?�ɘ�#���)F�e%�K^���i@3�ҁ��=[z�ڇ��Y�����q] ��.E�x��O���W�h�2�;�	th|9�`M�=
������������e�^����=4|_����2:�87c��o��LN]�NNY�݅8�]c���X5$_c��qn�F�w�s�!�F��IuӶ�B��[KrJ���۵Ƞk����[�q���Im4�x�o�D�}�R��qɴ���T�/�u���d���V���h׹s ����0	s�TuN�1;v:�g^��e�|���x�8V�|\��s�F|Џ�5�V�0��6�/�V��w��Ebn�V�&�!�G���x6�PW
�Ц{��7��t�i�Ǟ��=7�k7���M�=˷��n�;�pG�Y@�_��$Wʽ���-�b]v;� ��n�����S�_��v%��Պ/H����҆<(e�� Kk�[;/��|��p��>dN����p_wFY]�@ZD׎&36&9q)�d��^nF�i�O+F��vm!�Ǳ�*�̊%�	�&��}��\=��9d�v��W��?��I[�����(�3��k�;/q����NV�wd5����p�yY�F)Y���B�RV��]�R�>C��Hv�v��"k�f���.x�|��{��N+���E'�O���p�N��!�+H[ ��:H� ��Ӑ>�;ކ�Img�m=Kn�_��t/y Ɇ�zgҼ��"�������t�w�M/�֝�'�%|}(9�?�dR6#b�тg'�r�O�];?�t�Y��42�NʃD?6@T�.����<�W@��"��[�L�Լ��u��ȶhl��@[�z;�hr
?ޖ�T�+�D����Xp�s{h��i]A�p(g���&OtӼQv�L���-v����u��l�I�-FH�#Ӹ���ެNR� ��O�NO�&�����f�rEC���B�#C!뉍�Lu�m]G{1���˫|]{��*7�vx]gV{���o�-�:��>��� a��r�e�!$��r;�I����:���m9ۻށ�ޭ���\!)/��̇5a;�e��"��1m�U#f��Nl����O��VŹ��F=2�:k����z2��5�:�m��A?�ayʙO���
����i�����O�׏R���_���@�9��R����� ��u��B,�
�w
ⲧ⣸O"R��,$��h3ݽ��T���k��,~�Sq2ӧCr��C���-���_+���@����
���Ē/+n[��"�h�7����kC.>; ������g��n��ߒ5��u��(5��kH��H����!�Y�&��l���Ɋ}w(�%�E���XhX��03la�/d�a�b�`a���%�-l[�'h�
�pB���k$���C<;�׃}��8� ���m=~-փ��?�5��V���:Rײ�u��˾qa�F��[woغB���N�O�N�uvC��zy�w��ž'�����>��1laR���X��7�#�쀟C���^�b�	�F|<����g���W�I��K���v�����!h�=�z�Ǣޭ����R����b�ϥ�����q)�����o��4���vG����e;}���tcrY��J��@��R��f�{����k?��y)u�6��$w��5�Hy�N�,z���B4�<��k���E5+w��4����YS��,���%M1c�KJ1O;��2cP_̱��?Ɇ�W�_�u�֜Q�7J)4��7K)h�4h2x��wԹF�A��T;6�4$��-�+�n>���˼0#��@�9Ν05�%�׻��5H���9/JEb�k�C�h��L-e�=3����Kk��xJ��Ǧ���b��|��"$
��p�mw>�?p)6W�Dӻ�󫖯��cWN󪌪��.�k�%Ŵ�b�R��s�;t��w�7��՟Cj�����
�|ͷ�%�yG�#>������$��;֏@�$ť!n�	��@@�Z�	H�pb�[t;�ֺpJ�TZ�
��JJ��N���N��6A�hp�T_"T�n�R4��J�䭃��m�����!MR��
���5���ӿ|��>D��P���W\l����m3Nø��X��"$YW�	��m���~�<�^�q�4ٰ�bOEl}\�l>ڡahT�Վ&v�Q��]$�F�F���f��
F|�o�8���~���ބd�y�eX����y	�yFxO��Y~���K��f���+;m�vʄR����&�'��z��s���Y�b�ծ{w]�ce.ir1���ڲi���&�D5�MLۤi�6qM1Mr��BY�c���#�|Y����)˘�h��$?ڳ���e"���*3}yHs���ίD{P�e�Ux�79�vo�o滙9�9̇�f�E~�"�͈��i�O�������i	�I��,��	����T2#�g\�~��q���*P��YW��������,O����d�NM�1��w\��R�S�z�^��Yi�L�C�j�E�4������K㩵�ݾ�U�j���Z��Yl��Έ�?ʘ`�qc��jdy�pO�Д8f�I��k%�%�|��V�k6�_޼F�D�J�f
�3灔�R+��g��A��C�\��%�94g��/}��ŒgX2G�hj�sl�	X~V��}i��7�3��V�!\��h�0���t�!r���I�������ÕW+q��Ԃc��+��؞g��3�9�O�:K��Y��IV���2i�MЏ-��SyFl��{��z𵋺B2�t���^�w�b� Ne�Z*J֍j;I�ݻq��@ů n���f�ӯ�ܐ
����~�݌�}V�vˏ�z63l�������Ĥ�Ι�e�G���nByf�X�3�Tte������?1kҴ��Ɂ(��EF�d��Վ��w4�h�'��.iQ��X�I~��JӪ:}Ko3©>���D/�z^�>L(淽�?9�Kk�(�����}f>��g����{NMܢ�ڽiz�K����Ճ���<D��}����*�g`�!���#ߩ^�&���8����ټa�ܿI��dē��Ҍ橎)в-���}���\��NMoe\�@2�[�����8�F|��;V?�����e��Z�R~��Qΐ��ُ����4���ug�4c��[l�΋}M;�5�O��M;�If�ل�7����ƅ��'��޾>ܛ��l��N�͗��;$��m`���lX�m���,(��3��!�{��q=��}�e�|,��]4<u4�G���X����]�6<"��.jZԤUI�51m�-i+�$d�I�Mڴ�]�����4iI��]�
����{Ԥ�������F�Ν3gΜ9s�̙{g.Ed+[j/�/��Z�V�*K�F��w��د��-�ʅchN9��::�ȇU�ؼ_C��z�k�V�(1d�"�18peX�Mk�eqU���.���h9`��f�^��V]S��ï���(��D����M�,ֿ�E���o*R *D�8"�]�@��|�h�xi�W��[���×����K�Q/o���{0f
�"[��������zw5����e��1���(�ց�v>�� �?�,����!w�Cg��`c�#�h���mQ�>�CW��b�Z?�%�u��H_ɷ��>#�Y�~A%�����"�C�~rˤ��`h�-7h������ B�D�����f�[�>bH�3-�Z��Eh3�o�A[�y��Ow3Z��m�6Ld������ox��U��<���!�8}A,y�0E�ڒ�Z���}�0U�ђ�z/������Zf�f���D�[`�g�d����"���i��9��"C��9�T̿�k���I�n�}���[�|qN"{� �о�$�͓Rv�e~��wg\v nY��?\M{�GB��/���L��u���i~x�[v�L����<�c�F�k�(�@&��I^�2��)o R'������E/�A{��xL<E{	�Li���x���x	�A������<��	�d�I��ɈV_�0��ub�����ǹ���pTOŴ^�!�)7��� mP,�3���Z`�?��N�a����o�`�X�ǜQ���Xv���F�eO�e+I[e�Nm�q��v3�?��w����6(�:��Q��R������-ɭO��Z�:*P��<�����OoIk�!���>��m�\��bh}P�[�Y9�w�����2��L�K�����_�?�=��uuOe'i#�}���O�{����l#-�V�aN�#�(`��-�7��^���	=̴�Ú�U9��V�E�<��@	Jv��/3�DK���k=&X&��Gا}��7�N̘䋌�v�k¾yK���������O�Q�Ĝ/������9��{�>|׃�y�;ZNư4;j��9t�[��S�,�9��IXj�}0�d~��:��G���B��V��D �����{�a]3^f�-K�j�X� /���5Ϋ}t�Pn{'�7��h�yMmX�p�(���&�b]�%U-q�d�ɼd���B�Ol� Y��si�ns��a2�p#f���77 �s��F�L�^�'H�K�'�3�n����vۣmS�l��#Qm���h�����)y_��t2��9<��ľ���~�tׇ��PL��ۿ�Lj�͢�e���~��܊�f�z�?�T���˞D��m�0g�F3�ҥ�+�.B�Z���6����;�%�� �4��~�m��!ak^�iG�U-�E���0�}�$q�+�oj�	��wNA��ׇ����9���=�ũ;p]�������S�����<@�3��:@*=�҆`����64]�H���5��]v]�����)�4�����I�C}������V,ٛKjm/؇�#],�B�jY��v�:6��Iv>�&�g���r�QF� H���_���� /�/�Hקra��>\�����s GǏ-;��5�]|p��f����i�{z��x=�pỰ
~�I~�)=Ž��lr����?�M�t�|���?��|�������Ǘ��䂟_G/�Ź��~�����j�
w���E�A�ўX��u-`M��Ϡ%*�%�׿�<��\݋�4��gMه��޿��G�[$`��q�����v��=8�� ҷ�&�3?Kr��{�xD�F��]����M��n2uE�<7�}�K���?ĶQ�
�E�8��c%�TQ7A�PR�e+��?��P�)J;�/�_>J-T�Z>���U�Aʗu�*?�CkCTv�Ji�yC<}��ӹ�ә�W�&��c5�YU	u�Z���#f�E
� ]�μnT���{0�?�T�l�*� ��T�kPM;�JF�?�E������H�G���Kiw�Jw�s/X��~��z#A�ϨH�]�)�a�3���2�|�-|�4(�*��o�����y0��W�H~�`x"�ch��N�ȵ�|�z
��r �=&���޻��jn�^�R�]����#��-�~�.���O�
��z?k��&�/�`�BQ���Bo�u�Ҷ�Z��1��"����'���/�L�u0{��7�I���J��8O�9�C;�a!�0ڂ��b�ˈ��~ӻ�}?��ˢ�% 5j��{��`�3/k���y�g�,�ЯnYպr��i����������o�Y�]���_���P?�[�gv��$/����i�o��ׅt6H;��V�WW�gnmY��睠���m�!�&�/��Ї�Z*E멿V����R�k�M*�T��s�l�� +��i]��s^~vs�.�����`��ꌩ,�߃o\�������`>��,��џ{>��]����-���C�u	��χT���#�����&S�������-Έ��@���<(��׏��Zbx�����h�u�����;�Z�_n=g]i[鈷ɋ�6�霵eg�UZ��ߴ��c]n�ߵr���X\�<T�1�Є��M)�����@Dޮ�UK`.:Щn�鹐^�:�{W`_t���;�8�px{l�ᚖ@�*r2U���Z�N렔^���YQ���~O��o+\w=��σ�7��~g���1�a�%>'�_^��6+�\ǁ�cp�:dYQ"�ʊd��AYAI���#�����P8�Kp��#�;HmZ|���N2E�֥H<E����Jy�d�%��n#��Q$sh1�1,	��g��I�sw�@E�*Y���N&E�֦Dz�2��XF��ۆ�м�&Mꤡ�A�hj�h��8���3�>5�m�\��u���IE��8�fb���8��UgM�)����(�`=N]=m�p�~�I�w��~d2����~�
�5�o�yQ{h1�Q�%����L���������Ȩ�H���X���/T��lG��C�n�/�z^�3�<eI��������P���&N(���(���l��� ������6X��?k"�Rr�ݠ,��*"�b{O�Ua�4�I��'6$J���9��*��Űx����+�_ʢ����nMw{��(,��������M)��+���ni����o�:^ٗ=jVՅ�yو�,?���9*�b{�5t�P0��_�ϡ��c=�	r�^��<����Dn=Pk1�si�����D�[�޽-? �|p��!���X��9���i#����f��H�����wRk���0$�n/ө(�hޫ��t,�(���.4��w���G:$@�������i�B̧P�b�����Θ����ε�^�|י^���T�Tu}E���3Ыz�D��H0w�%��5��i���L�h�Pw�~�H_�?ٽ&�������:�0E_��03�ͤ��0�/'�S?ny=�i3���Ť���K���P�%�o_ו܉auM�ċuō�5��k�;���b]򑺞�u���@=�m�Qu`Iݞئ�Ht���%��I~[���FYo�{D���=�.\��Y%KE|��4?�GZh�:�\�H�^�-���LO�H�l1���>|CG�E�&rG�,�-��b���3ľ棝���[��֢��dXC+�V9��=����U�f�0fRخ�F��u���|�D�~�ܠ/AL��}�#'�?��˟hA�)�=Ro)��.K(�+Tr��u����������<�*�u�*��G��ȅڟ�!��v��Kh2ⶣ��7$�[��ndFd����Vd�g��|�$��[��w�լ��^��
��~|��Jm
�������ú�;-+P|�S������q�mN��%��zk
K����9b���	#�12�v�W�/�JəG_=���>k���깵��<O�s �V���4��:iX�e���8�)�#�b�C�N���_s��]�K)Ұ��i�ӿ�y�e2=$������w I�3_r�t~��֥E��"fb�?�g����O��r�~:�L�B:<�DqNW��U�g4��֗�N(?�^�+VN|�z�_�a`�>����s�ȫݦx��e�O|&W�o����〾э���0CDMn�k ��P8�h;��mL-80!��#�� ����P"b4�O���Q�X��_1��ݮWҭ�ݛ{�ф����QZ��i�M�^��ό�t'�[�����v�~7�l9pRmm:	��Z�4��N�w�-����>�A��Z����	�9V~�q��̹]��eT�nRҒ�qP����X�<n�{'��<Go������E���w�U��!��ȃ�N�)��y��>u�K@����?���}\�����~��%�&�o�n4�Y����= �7��9�Q`B��G2G�_�t=��n{:��~���d�Ӂ���6��n�J��|�߮t�^�G�'���k�_c��I�h2��)�ˠ�y�8W��>�����s��<k"<l��爬gM/@�P�����%�v�Ҥ��;�o�eȤ{�?��u��҂��?�����v�����v��̲|H�V;�
Z���?�Z��L�X��'�(�l�I�.�⶯�jj"�"ȃ���uλ,G�y��l�ݲ߼�s��{S��ʨ��	�L�4�����(�b;��K�q\���X�|�+��d��>�+���.\Ȱb�Rf��?�ja��!f�m��˿Eź�u�\o�#�*�Kp�W5���Fc��@b[M�P,oc�ho�bj�2֚�6[�Mf��|\]]�`%�`�
�Z���$wQl�mo�ޝ
˔N
<��u����h�����'l���@������~:R-�.�Sj���:L�Է]D�5K̻q�a�ZZG��;����S-��:hʒ��g�{1o����bP�R�68�w�% �]��w��0��['[&/Il~�H��1ʘ���(	�O�o�c��h���\ta�5�S��`e$���<��:>�zAN^%�`��zM)��hSó�\�ĲM�5��)q��7Nf��V�fP�o�k�'X&k�',�h�6�6�-|an��湋-``G�9l�8E�棑�<Q�{����a�0�n�[ l^���,۝��Z4p'�u�ۚ���ٯb�*�ka�ӕ��v�M��Ty�=xg�<��d��)����:a-9�EИ��4�x����B3�Yy��l1M9�p�m��]�Ig��w��+!����#�7z��7zQDY��g�+bi�Sח�!�4�ynB�� S\�^�axژ����*
?[���~�ow�G-H�����?��}����qo��<܌`VT��RvBA��$m�ơ޷�?�(e��W"�c��g��h�6���_�G�&r^��%94)�*�;���%���Pr�_z��~�p�(��:�?���8١����.��CrP�i���N�a};J'/�X�q�����=��\Iࣟ0%}�x�9C���CI��>B�|~����ɋ��Uz!����ԧ�iн�7LM]Mf{{YOn�:�N��f��A�t���.��,1�t�GG���(]�R����:`�&��tr�R��,/>�~n���3���$f"=;��(��'|�'����u4�gzd��d���;�����9�I��$�K�5/�&��rt���HpGd���5�H_x!8�B�fQ���7/�����D�,7�=�L���=����Ä^_��R)�=��A���"��!�p��	^"-�CeD��=�ڃ�p�=]
�6E�>����<08��a�C���d���q�Q��8�*$K�T��X�#��L�{͓�<�p�!>�Ca�=zt{|��^����,L� ��k�'���6�-Rh?��=?�x"S(Y��x��i�z�S��%%l���b�q��'S�O����W��D���Oi?I�6�.���2yz����ƛ�d4V�&��))&8pɅ���[_����C:���*��ޫde���:���_�Xb��D�]�:z�j��sr��H3����R��^��rp�XGĲ���.Ő�?�6��8'@�X�+�X��>2����{�;��#�,ˀ�J��e��{��w	�e���"�ˀ��4+�Y��d�w
���#��W�uP�^IZ�Ҧ�6ў
�xO0�#�?`3Զ�Xx���冣2��g�lTB��sϻ�r���(˚�t�y� �X�7���!�v,'/�D{���B�O/0Y��V?���Q}2�5�UP�y����Z/��Y}0`av�b`<K��(@T��;D{1�*��H��*(���śq��{�`�S��ԟrm!M&���<�+ҋk������HJ�vX�6�M�;��˜�<���b�2��h�c���e�&��p������@�u�8:���c�TP�dʛ�|�\�?�E~�+���5E��.D������K_q,<C�98���w�e�
X��V�u'P�cv6�i"7C?��û��� ��lԫRv�����S��vr���;'yOp��|��<�ޗ�p���V��m����}h7�������?����IP48:hvW[p�ݡ�,�����Iz6�2���K̥�\��:x�]���T��M
��o�tY`��&���ε�$�� �K�|уa�6�G_4eٲ��+�s��f�c��`� l�.��GO�!/�Y��7,-$!��ڇ&�ߩ�Xɵ��<���uY�=A�U�D�҅u��43��܇�Um8����UuD6����xx�԰��J����(�����"�0wz��ǧf�^>y��2���L�A�ZX��QuUƀ/i���4�i9���J�����i����n��t��X@b�O��Ԑ������O�D��ϰ�~�$�O�0w���%~pz��,����xn=��������5��E�#]�%�u =ɢ���� g�87����V"9���#����ޔ�5$�&|z����4��G~醡�aA�~_��ڃ�n�K|X�.���N��}����&ml[8�5<}����
SXL��A���됰rV	�3�eI�����§�ރ������t���5*�8�����S"��pca��Ƅ#�����{(��$̓�n��s�<}k�EN����k� 'xW�SH��l�]��d�z�lѴų�L��$�Ო����@�J�-\d�����+�ǐG�7�ڷ�9������u�?�47�vm�4��X	~_b�;O)����(s�y�烍h��6>u	��m$`%#��=��4�Nf�Ot�1��J�]�
��� ~"�aX����g��S@\v^�G�崥�Z��}=Y#�A�[��@�k����Ü����٨ި.��q��C�S����y��)��-)�3k�c�hO^�K0�����Q�&��$1t'����n<f�h��M�M��v#��`K�hSj�ʛ�7��/lI`��.�����!�[Ҳc��F��-�{�Ʉ�𞱒;�w�zk�T}���M���=�����l��6�S�Mq��A��2,~Vu(�=X��;b�)���n�d�=�j� f���"��Nq�-��S��'�G���M�������H>������a�|�$�W��0n��UYd^U���ݦkg�Y�^F���u��:=�C��� t��[2Kd������?Z͟�×<�x�e�p�Ne�ƚ�)��jv���&�Z���C������b(�"��y*���w9b���R�{H�i��]Ց�E�zE�oFXH���[��߻ �����-	����;?�{?#�EB�o_�,�� x/��%��f%x�u�/'��ݹ�V�6�Jh�ec���Z�h�ŷ탕A�������`�6��UI�{�~����/�R}9�)0]��ު��'bV�3\�� Qݿ#����-�w�*�fȣg�a?�h9Bg!
	�o�s �l��a^�]���5���*RcE��A4�s�j�ª�Ԍ��� �8�h��?���� ��<�R��O`R�OR�� �U�9�9�?DZ��l����XC_iQ7#�;	9���Pp��ȟd�c��F�"�J�%��+ ޺����X,��ڃ���u؆��CHK�\e�o���C��Q�"�'�k_����yIF��K3�W�A7	m���ee�XVH�$��;'%��c�z �]�3�ׂ����!��/�W�E��|�/�V4"��A�QЉS�P�N�oՙ��q���x��wth�$V�^�3K�KW��/s�S�A�U"[�n�I�x(�Ucs���$��璸ge��	��O	����F��|:��� ��X+�~"B/rJ�P,�y K
4c=�����&L�X�J���ɡ����XdY�
m�mRs��7x��D9t�<�c`eJ��`o����ϣ����ٷۄk���1bV o��u,dhv�T�����VHϭ���Z����M��x�'���#i�O_I�|�����O�7����F�2>����9��kɱ�
�r"E���d���JN�s+��:�ӊ��{3��0����p-� �`؟#��A@ҷ;�Ч[c2���E��
eL�D4|0�^�^�����_C����'%H����jx��^�ޡ�\ނ�x�0��7{P�~�q���K�QT����y_^��X0��W�����2�]=5H�S�6c.UO�&�*>u�Zr.0a?��e%��4��*_y����ɾ�ڝ�ŷq@�^3�#���y'0����{�]�O��}L���.~_u��i�.	z�o.�.�(Vc�:A��@���rD)��:�XUfa]�m��C6{ϰ~�����c���o��\N��f���u��~��ϣ��?6R�;���6�'�LpMb�3� yZ�OB��Q�!��9�Y�ވ4�$����~!c�= ���4��	�r��8ԇ�-p��'�Y�Cpҟ~Z�K-��W��X��|ϴ�zت�}�3�Fh�QJ����|(� z�=a��Y�ﶣ�6�3����������:����"7���)��=FK�>
�g<~�c�����OI,����"�笮+%߇�Ѡ��ă�;~��R�:�;E��uV'ZǑ~%��@�?�ɔ��v���/�u��5��G�����H]w;��ȩ��?�-�w�rq���.�4+�V�B=���2�#�P�ytY�{�:*�>�s�
�c̷�$(����Gb���2��x�*� ���5���q��~��#!z�"=�-�5V�/�� �A���+�� |w �Z�BL,���X�K>M���#���>5z늑^HV�fy6˘j6���qv���>�8�o�)7�����bc�)}�����U�AF��"���JS4��^NH��H��)��Լ��9�lə싈�m;�}Bi�g�i�.8�8��rh 9�� �*��#5���l�pQ�S�Uhӣ�Lz��t�=V�d��0��g�T���	h�(�0�l��MQ�d��jh!���l<�����O�8�2�F�%ӣ�{�t�B�ä��c����y<O-�ٺ�F�S�]}�U'Ǿ�[_�w�b=�.�+��w�F�X�9kڼ.B'`�Wv2K�1��+�qR���$����{f[Hn�8ge��G9��	tD�,�z��#=�P��S��Cb�2ЃЃ�2qK�憸E�)Ɖ���%;.�JN�^�я �=����2��F��3�ױ��OýA�o�{����]��4��~���fW����j�ݟpzh�'ֻ�3��ҁ��MW���&koϟ���w��)6������<u�P2�s�vi@�}�v�����r���a�������a���hf��H����Gۏ�����	g���w�==�8G�Q�����s����|?��$#ί�2�����w5?�N�m��E;��ݿj����~h���j>�^։?�����f"�h�.盐�UoA����dכͰ*��7��8�T5&J��on�M�0����͑��]����H��ڵ���]���`U�\s�9^z��9կ{]dUH�:��b�'F��<�����90<��w �`�`x2�Zd)j�ڡi��
�$~�.mNrQɗC�*	c,��[.�iޥ�0�ՒtK>�K�uJ7û����}�c}C䫴.�[[��=ׯ"b�%@Gx��7�j;�@�������r�X�TGZ�Wʿ!y/l?	~��|8�����\��-�x]DA�5���*��ڟ�J1���b���R��>�����&qxlT.���q*���I��t&���u囁����s����#�:����-_^�GZz��R�߽b]9�v�L�^�Q.�9�֢�t��r�ѯDS��媇��R��V��'��/���f]��K���=xy�2�3?��`5�7!�'kYWK�v;?7�#][�Ɠ +B'����wws�}Ũ߸z���%�o@)N5�{)��42~2�#���D�~�L>����&����L��Ke�1՘���7�Us�/�_CBZ!!�#�3�	/��Z��9�Ki��;s�~������rc���t~��.;�t�4���.n�<�ôk�i��z���W����n~_ML-�������q����}�� ~?���w��u���u�����ש;)��9�N� ��X�2��3��)l\��戀��$��>�"�#-��D�م����M3� _MOa��ݿ���~�(�w�)v��@�w��'x��[�"�i����"5��w��︓U�Y%��v�)9��(�]-�`��l��`ٌ�w���m���t!�h~/��U��K+D���=��>	�]�)�
SF��&��a�
��#<���b
��4X\M�?HE�S%?���6��\�@ڄcz�˨W��%�/���� �hOr�o>]b�oǔ��66�m�۹d.�:�U]��jD��V޲�r��@�ky�%�XOlȸG%�k#~g_h)�>F�K���c5�������'e����N���NY���.���[u[YV��1� ��:u7��i�L
���3���t�Ro����P!�_)�^6.�>������PL����u�Ɗ�����P'��������'�͈�̀]k�W����m��#���M�5��Cg�-�ʀ��a���~Na5��_=��M�FY�/�#�� ��
�=�yp��B?�'EYc�cy�w����
�n���[�}*��}���z~��3D�!�?vOq���Ȟb�����>~QD��]Ų�]��t߹���SY�Mv4�XJ|FD�EP�T�"���߸A�]�y;��ɯ�����!��b��?�:���N�Mu���.<�ab8�A؇��[q��8�Q8�Eݙȑ<�Ԣ��TNeC<;�����m? �s��G���i����	��/�1�MfL�D4�򠸃�)��n�o Ui2���%��+گ:K���v&�~h1Y��R�/����6������خ-9�Iό�0�`	��iE*nZ����}�t󝑎��*��l���㽭��]�z�1��)l
{jib���Jc�ʐ�l(���yH�zi��D�β�S�@%�R�S��'A���Ex;����Z�'�\��PX��\aÑ�&Źr;�i��<R#����~L�#���]]�鹃vu�����ܑ�����7v~԰�[��P�M�5G�.Y������tf���5��;�Y�]�g�u5���Գ��{�5��B��q����̚K\=��e6�AMp~A���`�9�Rg��n�u*4��I���<�Q�>��V;�KbX���N�R�ƕ��7c=)���Z-�3��A���
~.���^}��]�ܔ��P{�X�,I ���/}[H~�F��-�Z��Y��Iw���~5жg��m�}�G���!��`�N���zC��!��\���s\'�}#��[�������<�\��H�X�Wݹ��7�����r�ߙ���;"-�d�� >���.��\�g��Ԣ�i�'�"(�n�w�_�Mj;Z��Xfs-K���G.�K���>�~sllC�cy�Zǁ���=���|�V�a��f�h�ww��=�'8�:��d�xZ��J#>��x?�AX������(�n��*#|"M殷0��[TJ�g���{�o?$��5���o<��<��B�a�'��1�O�ўȌK<�ȼd�<DF���8������{P�k�����F�\d�� r��7B������+n4+��<6,�i���f�������p�����(c�gm3J�y�Ө �~ݷ^��9ڌ���3�
�L鹷H�#o�b�R�I�p���N3P��$6�S@�c��#�,�C��a[�-X�)�l����Ai����gP�Ć���n�W�1�#xrD��sd�����m�!����<S��/s˽��8��jg��a��Px'Zp���׀e�RH�%�t�n���k"<:�K� w\�z}���R�ԙ~�L �4I
TG4;�z���7�3�v�Z�����w th�EZ���P_?14A�Ih�E��;�`��̹!�RP�c#�1�[�Ν�������h��GT!�[��/p:җdp��T:ᖤ�zN�u{[۞k����}�������]�#&;�l'�˯�f�%��'�ޕm�0�p��q"�욚�����1��9JGz��9X+�(�i�T[�*��TE{��<ɗ��v�W�Ny����چ����c84C��� �:��T�{�4c��=��4�Ƭ���ʂWJj��˷x�����f;	+�Ep`�u=p�<�`�k��s�!8�^[��-��3�\����O�<a6��Xl� ��rb6qո|���G�σD�Ub�*@�G���Dv_�����B�R��Hb�Y	���� �0�pz�|�������<Wl@Ϡ@<��
_+�Z�����_�W�c���/	�\k^2�,�-�Ұ|�G�k.�.�c���e�q��f�b^�G�(6C����y�K
�]����H�-�Ɉ,�q�.�/�}��(�� ��"�Y�G�x����}Od�Ю������T�x� 1-����<����F$į��?��Vö�.�EN/�Gs�>�ب>���x�7����d��k��{z����&,e�l�o7�8�ߝ�ω�<�*����_�	��i��?�z���fg����L�Yr��vbv|ޡv�4�����Mo_�n�p{ڗm�x�Pb�����}�����SՅߔ�}.���mP�E��>k���4'r�m��5�v,��G��͞fg���f�5����~�~ޱdj-��X��5�hz>��f�cVr	a�]���Е�SlO��I��կ���Q"=�xh�=6�%<ᕳ�m��g8�#٣~΋�f��-�}d9�������_��*�4���oA&�����A	����R�J�x��6���d��`֊geE����[��pl������v|�jx`�+q/������׵�]��C�ۻ��.�ݕw���܈=~FC��c�y�=�Wl$ydt�|�d��)]�%�:���(���)�W��y��H�1:�e�h"���V��?����=�pr~֌�g?�ژ�����$Xc~��:C;ǂ��,8�x��}eHg½X��J��.���1��b�ڢ�S����K��HXåw��Y�p�?p%�d��MI�J��	�vb	�)N��}��{��G��!����q����z-|Wp������Ϫ���<�D_��T5긇�7щk��֘��	ğ���3��Fp��w��eOA�s!mA}�\�ͱ�*���Q�!�Fp{MW=o^]`6h�٧����h��{��3��}����kC�	�����1����;��W�%W��_���bں�y��#αXx#����}��^��u��̵�-���x줆CӉ���^��QO�qg��~ E}�r�8���M˛�j~G�����we������^���ei�L�H�%~[}Pc=b�GL����QS��̌� ,#�/��J��pj�����!�0+}㊓М����$.�Os�}?�4��N�fbA�S�m�J�Z�8pڂO�Lt��o|�R�[�Iy��Zȃ�i&���~�8�`M���sE��迿�\�nM���p���X�L�[&??�m-���Z�4�|���Cvj?����+ݪ�d����)h��%f|ٮ�D3�����׷y���$����bQ��)'����	e�L�	/�	+��"���yS���G��->����:H��4�}�^�n-?���3^&�%�aI�q�9��x���1�<���	�}�
+��Z���ij�{^ۛ��m�<��A�mA���kۉ�N����b�~�GN�+o�8�t�P�P����]/�Q��Y���G��-T˭�\�ۀ�Wa�X	��= �c�W�h��)Q����ծ��8��V��i2ŭۢi��*j�7����҉�XF��y"@��mYm�槸� ô a��u�]cC���h�#n"u�'���y�Pyl㖉~�$	���}�^�m�;Q�a�����s�T*�ޒ��cP�̪��Úf����ﴂ>��>2�#�_mM��T����s���o�f	eQ�l��#R�B�ɏʶ|�|�[�tc���iω}Ă��'vmq�2\�Q}J�➍�x?��&���W���Fxˬ���4s������~��_%'�`��~�uvt�hQ�~ӊ�R���]V���I�����}
���
��u���vkO|�˼z��َ؂|�8�m�[q���	ߋf�h���'eHY�%��d�\L(�+WfһՅ�ui	��׼mh&��J�y��?���!�/�_��%���~./ޱ�	e.�e��͔]��i��$�J��^&��(��w�__.|�^�{��y���8t\���1,���ok���ז��ӚpE�X+@��P��U�_<�Tx$�����9�����|� :(o����ϥ{8���5g����Ώ>�B�.L��\'g����kZ=e�<�5�Q��מf�+g��3ѽ�����k�b)�$pId��)�^B�N�r�
���6�bnRX���&7 o�F<҉xN�z���ך��<g����˨Ғl$�_'30o�o��g�["��_z0_��?��'u%��
T6����ʗ�1@�*�w���b&6�z9x��W�k2X�[��Ā\�D��ڡZ�*�I��C���gL%����L$y)1�B�x1O
X%���?<N���r#�z��1ĽJ�&r���D��龏h?*��C%t/!�p��>�IS3���%�����u]�(�#"�=O�����=3�6'庑���y���WI%����v����x���#��-7�g�<1���pH�L�u��ư��[!A���~g��zt���&Ͽ�G�7�Z�,��kԛ�zYW�f@�r �ŗ��P���$�o|�U��q@�w	�$a��c������̳�N��EamS��.�8�cޛW&Qg@�*p�G�.�j=��MH.�;k:��L����PO�#º丂��o�����P������{Y�+ЅGܬa-�&�tM�Gd�.��O�ϟ�_Uޯz0V����a(�S��,���%�;���U�'M�4���|����ԩ��i�Y����������{����?����W�0�	~�u�*�N��giHI,��GL�
�O���������Cz�X���Q�˥�~�'}��k�����Z�C��>R��W�a��b���Y�[����իO����e�9}$�䣨�>�v��J��lv�b����Gd�M*��f�n��֛K��p*���M�W��@{p���S��}}�����HF_�J.;չ}�����<(��67���>FXD��������u���~� �G���0:�/�!�{��%�6�h⹶�h��\���g@%��J�+�孈��q��8_��"w���)��!��K/��ICW��Xi��:���i���=�(�vA3m�MW�.&�D_$ȟ!�*g�?"�&(���D*��A�O�y�u��Q����*�_r����~㧚�\Ԗj6tU�hz�¤�9ї�	�[@���P��G!� }%�GWo�)�\ri>7�5t��O����H]M0�b��ܟj��T�����qӮV��������S���U$#*�Mq���&\u�]�Ug���:�?���� @��Ѕ�kx:��$��|D�Ե�G�������u�~^~H��݀���}�i�!��X�s�|�W�2�Y��	z��D�/.�1���an��(i�[�;
\8-а�a~�J�2P�"�.>jUxo�As��󂶆j.��p_��_��)��wI�vQ�C1�{��^�� u]�j��F��'��W�-X*����I��US\I���O��1O���d����j}�������5//�c�<1�}|�����!�/R�v�!�/��~<D}�h�ڵ�OD?��_��v�_5��gK}K��沽R���+m�o���ی���e%���|����Uo�����>:���.��eaT}$z7�g\��*%�>��yã�X���:'�͍�#^��t���f�N���Xr�L�U�9h엦^)�-�9F����n(GC9	��P9�����:./���P�\��GRx4�2_f�<�����(����F�r�p���O�u,� 2�RT���h�m�I)�b܏J�O���ҽ̗+Žg�z<Xn�n<6]8G�R�	,�Mp㒤z{n���x���&�����a��ΧG�W��O��Jh����a�ovb�3��|_|��W�F���SU��Ќh��I���)��M��g׃0�|YS�KI�{�s����{���^*Z�zYS�}J$⎁o���;�/��>i��]� g��K|�I%�7)�oEm������n�HO�񒁫���lF�M���_������(�m��ڻt)�M������<�W�(]9����/�%N)p������%����K�w=8%Ž9����0]�M�����/ E���%�%;�{���P
sr��P�b�$@�fg��+7��Ė�rC��8	�JLM�m*�[q����Ð5��Џ�M���}�8���B�x�[(�`�8�{���sn�>"�����F�q໌E�����Ot-	ȿ�H��|�r	0_0��7��-����֨�E(�l�U{6�|uC�ލ+��/�7��b�-[�[����R�1��y� ����}^s���U�t�oxC�0��K|�d�o��l��w;��&��,�z���ռ�<�c1��+����}W��W�}W��41'%�sz
�q�����;�s�ƕ2,��Ћ�Fc��c�F>��o�9!���b&4�o.uzn�OW�ç�| �?n�����7\gչ�c��k�)!��̄%���a~L�ۂ����w�]�&L�>�s���¬��U�7�άA�����&k��9���>��9�ϣ؋N[~���Ιe�t�g�X\���M��Q��������}re{��D���̅��
�����mT���	�����+1�X���B�6b]�WjݘSڍ1�.9�X��G�$��.�l^B�����ׇj����a�&��8	J�2�5�R,M=�d�w"^#(dR3c���<כ�?0,֗����*�7��X^^�7Pꃱ	�{}f��f��D�s�	�_|��|���3+U�S�^������>%h�es/9�k�������W�=�P�o�L�WL��Yy�I\�n�܄�H�q��S��k��ٷ<����9��s�����=�z�@�v�7Ҧ\85�OA� s(Q,w���rf��3��}A��;�̱K˃�������K.��ę>D���nni�/����S�V�>�b�e䵆�͍GJ�	^�b1|�57���ߣ[�v��*ܰ�)V�US��	�c�'c��D�b/��	n\��`5��RHI��G��{Ƒ1y{9����R$�t!Y�32w���+;�X�O�e��4V���Ga.D�}�d�zn٩��1ɮ��)<��=��Px�;���S
�p��ä$��F�}_.��>Sx��^�=�c��{����l���d����_��3��r��|O����/�tU�M������~�׮;�����Mw������s�
�J���h\�j�P����\վ��%��o%�)�3$\�S����8l>��66��л#�P��<t�6�wF��mj�Uu̹��S�q�> _�����3�)4����x=�x �(wU�:+䅾mٌ��v�,4߆���%���.�I"�^���5z�Om�^�����\5�}�D��Hf�/&r=�O^�/���>�����_��1i!X5���x�g�iU~oN�����*"�Z������ �!}��q�q������l|_0[rn�i����y�[�%�^��E�Ql���{C��O���н���6���vU+8%׹�i5@騳	��~�Y�&6��%X�Y��s�D]P��9�z�3���p̤�$r�<���o���9*/�j�`u�>�l�RsI�ǁ��+�<�u�u��7��}��M��$�9��y.�t�)e���i�9�%�S�Z�ٶHn}b��������Կ]6�����l�H��k�ʬJv�W�r��L,�s����
0VXqÝ.`N"؉�����n��"�~
�4��&ҽ���e�.k� d�0�ݣ�g[�?�����_�b��o����I��I�G�Qm��y]t<b(6>@���!�ZC�s,t W�5�k?����F$��"��Ep�D��k�<�a���&���'�+���{՟��Q Y�zt?�D�P���Q��梻�<t2�6t
}�>@�Ѓh�@5�5�zdG�ȁl���Mh3��h�D�Q*C���
mEh&��6��.ԎN����1��M�r�kb��ߢ3�M�z�
�z��~�~���Ρߣ�����=�T��ˑ��S�GHu��N�<}�]>ԋ���@G� cۇ��e�D�E;���� �L�)p͆$EK�2Ul\����&�4�IS�N� ������Å��_C')�Lp�Y$���Q:E܇�o�+|O���g���*�"�o>r�����=@�o���,=����0�rj2B$��~ͅg��]v�]?�fv�\p���Y�$�h$%�\$�e���/Kn�i,A���@��[���Eby����.p�ĳ�c�D4#H%�� U�z�hBݐ�| �
�$���$	D�|"�N<%�'�H�3DdE̛�4}G��)�I*Q*�pK4I��!���p�z�)�/�4����A���~��� h�4�$|<7���h�pvDN���s#�B0�@�����="qy�Q/o����c+ �V4!���=@v��$A��>�h�����ۆd�n��	����i���H1V�q�G�q�M��C,\19a��*	�W�"�Q$��0F��^%�u(4�#}A&����^��|U�HE�Vw�bI*Ҩ�k>O��� W8�͘D|��ˑq���dF�?7t��_C�-AL�1�p�-t���Y����O�?y�:W�Z��_�)u� c�L��<�݅�~|��D�~��f�[� �gmAr��U|ͱ#��>�+���5���şv�b<�9���)�?�������^���,M_��������a=���iz9㨩���(W seuٖm�5[�����VU�lE���s����
[S^��J��w��k��e[���MȖ�ƍն�򛐭����Q������PS�iSx
���򊛔��H��Dw�4�l��,񟝷䑈$a�� �"�I���$A'�RI�2��R�`�g	�8r�h��QY�"�i'P�l�c�ͣu�",��W�6�6�b�����]y7� �1�K��:�7���"h�Y
t7B�"��y��3WM!��
�x���9bzd\����|����>�|�O~��_�ͼ{�]S�����g����~�;�m޳w��O|���ly�<}�����e8��9�Y�G("�Q�1���_������eH~��;�*\��?����n��'VCz���.���p������>w�����4��&)rT��)>�ϋ�0���%�5�Aė�Qi)���<?-�Q�rtZA�NG�����bt:jL:zL:��a� J>*M���RĿ�k�N�c�1�J�WJ�N���i95:A���C?rLZ9&5&=&�ۿ?��p�ijO�PCx�������Qi	԰?�>iX}|�Ǥ�c�cҊ1��1i�tԘt��4n��1���A"����xӆ!LD�P@�؍��/�v����V�'���#X6C���+�%�>u����Q��k��j1�n�U+^YX��Z(�4�ʯ��;���[\J��M8�&0Ŋ��6��8?��]�2Ū�:�Abβ%�W�.arM%+V�7
s��ꚺ��(EX�nڡ,��!�"�KF��ٍ7���olG�?l�Z��pM�+�a�����P�	bs�'x��̯��0s֦J[-7����� ��9sp�u�Cẋ���QVN���9s����Yٳw����p<�k���1mu������|�-#��#A����^5k#�B����++������Z*5�r&������zf���c�^m�:��)�x�<���d�ٺ�VS���p��T��^�徔�G�RuLcO��V[�$7V1v!�������1�LmeE������9k+��J����I]]c�y����d���A��!JC̴WUτV1�����n�_Zœ�h�ׅ�yPW��UV`�lU���2��Lu�t"vE��LQ^]U�P��?����_��Ys��9Y99���|��k+�LPm[Mg��(����X����RU�M��kJ}�mk��554n��-���ʌ.e�Z>7Gǈ��V����+S�m�c�f&3�Qc���/�<�l��Q�� �|\zƌ�Tq�<��؜��ܦ���+�R�P�x��P�71��Ql,bB�e�_��i�"B0Ex�l��U�gΜ�4H(6�G����:&g�o�xR�km�+�3�����~���R89�2m�u�y��n�cІM0	ܫc�1[ �0Y���钳t�0�φ{� �gýHR�z�f��M���[�H7��, r����9�x/�T_[Qj+/�Y����S�8UQ[�$��)**k+nA�	�3�A����^«�id�q p�-��;�{-SS_U���+\�(9�)+gtA!^�u��rW��,Y���p��:&��Ƕr&��5&0�K��7��tխyP`00���q�j�
���t*��Lh[ϗ0�V��&��g�g6Vl��f@�����	B��l���$�{[핕�ڊ�r��f�@����WUW_���+�����ں���
Vy+Κc�w�B?�b��r#�k��4Y�N�X�޸��0p���R<��z5T��bc��V�Էv֨��cD�N䱫KW�*,^4�����z�7��u�J�~$/T��s�o���l�:BTw���l��T��T������"��Q�F���<{��f���z�ɴ�=?��>����(n��C�
��g!�����7�ʝ�R[Qc�U�)Q(�%����_�� z�|K��T�~��))b��tf!�cHMq��0s��(�<��[4����Ǝ��i�/gv�Kc���9�����Dؑ_̒a�7(t/~L�����7�\�B�CQ�;MER���M���rt,{��˩���c�$4:&�b����Gǡ���2����lt^��/�mL<�}��l�d��c��O����r�X��q�F�~bt,y6+\�Dzc��-�F��ޠ����/u��������3�ƕht�o9����:Խ+����/��㐞ͪ�o��3��<��^Uߐ	k�̹93k�g��K%��⥫q�u�a�O��1��Oz��&|&��RU�5�^Y��.D�qB�"�+���'����жO��~�~��aw��wx���;�s� _zx���ށ��w�O����Uw�G����w�s�����[wл2�fs��w"Qi)�Pe[J˸-��l�Jįe7��2��muu5�^]VW	v� �����C���JTVY][��U �,����5�J�'�UڷW@W�+'o��^��Հ�-��갋��̥�g��͞9��ZRZ���vX@ԬZb�/o�mc%.�yku�H�T@�-���\�(�>�"��渞`�G������#0�h��ٝn��c�N.7������۹ip����������0x �'��B�Fۃ�0x�V7g<|~l�K������v�P\?w�_�G��O���a��a�0xw<:�N<&|��ǎ���a<���0��(\��:X��o�}�f�r���:2�.����M>?8g>�/�/�(f��o�����`p?�&��g$M��7F��nI�|�ّ��OIK�t�HZƧI���m$�����|:w$ɧ�F�J>���u_�ĭ����c�KƤ�Ǥ�I�����>&=eLz�tԘ�dL�F�����t��{<�*���]����*~B�	$^�D�?h-�@�'��"��!y-C%�qtO�n"��/2Ոzc�9q��)ƀ�.�?��R������}o��W��	@�1��<����*��s.z
����W�Z����K��`ߢM��l�p0�Y9t֯$[!M�eG��|d��Pn����3q'D�c�=�����>ɲL>a����� ��y��}�����@Vw���^'�保�=���I$�'���@�^�g}$� ||��1§�Pnd�UJ�h���x1ξ�g�u�,س�4@?�h7@����� u�@'$��$���?ۗ:
�#�=���-�%\�>�Z��[�,�!0"��-�'Y�3��dHT[Fc����?��y辉B�!%;�~���,ط$P^���EX'�������Bf�6����1��3����U�A��.�A�6��������M����ܗ߿�zO~o����>Ie��:���0j30�����I�6�e^��2#�6��nV�k�E�-�~[�ɛ�����e�m��Y��cj׆���¡1̫�<z�`O�ף׉oK���d ��	U�%�~����/������. �u���d	]��,�����?{�-���o�r�Gr��ݽ8����C#0��/�"�
��9��x�Q5w!p^�-��Y��ڻ?�x�aH��B�~j��AQZ��0��"���O,Z?��o��}���=WsW�����b �,N������޸A�M˺(ڛ�=����=oOOnp
v�I��Q�ϗ���ݐ{�rK�ܴif̴�#��7��|��	諬/?����Gf��0��x�a<����:�Q[Q�b�ʔ��̪�����ƂV
��U+�b(G���ѻ�
�J�+��U��,,q�٫�xH����^U*n\+�;��UD!��[������5�6Kܻ��f&�H-����~�?�������`Wb/��`���r0�x6�j�L��΃xU0��ث�`�)_�� >�� �/�&��}"TD�R&�Op�g�꜅�d��d$�=�w��b��E1���Nt�f~Zv�.Dw\�!�=��"V���ฮ�1ж,ȏV}�4GI9`H��8ȯ ��������M�EWxy�%� ��\�_��ϭ Ə�����} o�����h����h����h�	:?:�qI^��;҂�y�d���U��r���)�h��6E�L�r��@�$�	��e�8��Ǎ��0��x�a<����B��B����/#�'Jt�C{�vO�1�ǖ(�C{�B�N
�gK�u8X����&��ϼ_�	��zG���,ơ�\j1�8�}��gk�}X�=j�Ƭ�B{��f�C�����|w�qĘ���i�PPh!����"���|>���N1������\\h���`��(����*�1v��~1>.�'Ÿ[��b�c��?�oh��b�y>��zc}U]=s��왆̬���dַgfrR�?A�髩��ɑ}���Ⱦ��p=r[�dD�Gå#z=.���p��^��G���h�bDoG�#G�{4\9z��<
1��G�vS#�b��p��y����{2w����ه?>���>q�>��O�K��o;.(�!;2��F�.� ����<���a��c�J�f��j�C�hn׊p���|7�	����U[E:�c�4���������X�Q�7���g"�*�~�^��&��o��v�o��;D�
5�7�,1���x����_D�����a$��ܪ'kH�ϭ�KK`�T�:y���E�~�����[�m�H�]��Y"|-q�}��f%���I�����t���w����7w��QlW�8�w����4)�k�|bI�N��t����|��$��7��#�+��}?�^��|���$��?�.�C_!���,�-R��_������&o/���~��_������ ��(ϱ��A��۟;ɢnO������o�4��<�QZ����E���ե�+�7���u�5����TV��QYQWQ>s�a���H����VSck,����iD����R��1	K�f�(�Q�V�ЦrT]Y��c��T���K�K�敖"�K�h*�4o���%���9�� -^��4�@$T���...1�������U��rM�����3e��|{��LGxu!�1G��(���n9�s)'t�gt9�@�h&h4��}4Hxys��1|�b�D�o�n9�SZ^[]�٪�+��Fb+KK ��^UZ_[Q.,,qHo��	�G�FN)��`��h0>�4��#����<�46:LT�;Y}�j4��h�Y۸�ζ�!�Bw�u54����b�����hDM]chc���<�^.�rM��u�͈��l��Y�XUq]���PEM���jT��j**mQ�sT�a.�7������MmE�	"�$��3k�y��Y��C�+���hcH(���l[�@L(=�f�}�
��|��(�6�����1��PУ�g��t��Y���1�Ǟ�M�ŧ
ǔ�s�C�c��ox~	k�P��z�����w��&���1�Fb��z�+Z����3���U(��5�P\��ʇ�a�x���1�ŵ(Z��b�=����(Sr��P�}�����X�4��F(=��eƖ���E��KO���fL��z2{���=��ӱ�ǎ�U_S����i(vM��1�C�Y(~Nr���S>�_�⨯���c��؃��|�����w:�~��/�)Zg����W��q�J�y^:�.����	�*�1���d���1ϽB�/������,j�?�y��A�k��ˏ�O�ח��Q�C�C�x�X�9�=���<,T>��/<��U�by�(�)��s�����3Lf��S_mc�P�B����������0��?��,��k��ܜ�;}�q.�6����̽;�0�����0+�1W;k웹:&Ŝ��6d�aVTo��a̕��-��m۶���2��YUQw��Ic��y,�a��=��������T�?����^l�����(�ET�}c}��:X&Ϊ�a�V��75b: ��*�_��*���e�7�	X�3�+�*jl�̲����2��^�ח��ƐZ�������%X��J����6��pSa��F\
1�Cu�3��L$e䳵���T`������,:Є���:{���oL���*��	�k+���*�K��3n4�m>.�l5���6�^�	�o����� ��f�U� �X]]�������Å#\�]�?� )�UW��T��52�-�����r�R�)�����R��,��h�!{,���s���ڙ���BP��^UVYb_��yT������XU׎�W�l��0��kg�5:*� c0X����MeUu��"��n�
T���g��pq�U��1)XG�6�K�@� z�5��WF��T�x{U�07��`g҄��[��U��&�)X
�@�PX�]\_Uk�\]X�U��1�UT���Mɷ�a^���6���?M����%�X}%����k,:� L{S��PT����{�	{�� j�[qK#_�yT���<�Ye^����̌0"�⇧y��G�G\�����b{�2��ϲ� ��"�R���LI銼o�HM����J�1XW_S�0 �|���d�Gc)a�L�a�)��QM�J�!�u5��p��d�,+-�Ti��<��1CO��r>�K̹ţѪy�EPE8c��QQ�%l���OB���}��* Z)~u��^U�9����V1X���YU
��3DPE�lUuU����jl:k���*jk7�W�)!������?�)���ExW�v��&q@�
�~>�g8�#f�A���xv�}q�7Gcd��((\\ X;��_5C���A��k�u��E��ţ jmD�+"Fx��������������7��+�ŗ,2".��l({�"��c�o����(�+��Q�u�|�����Y��������PG3��E:+䕀��s<�mw�����³C�ˋG@a���S�Vޝ`��ث�Mռ��W�U�ޤv���M�����\A(`����%#��p�������F~��{�V��,�f�h��|�G("� q����7�1�f�*"@`»�����Ujx1G�;'�W6O�eݟ*20k�@h�V�f<��8��F�_�o��k$��*{x����%qm�i;��z+��
<CED�_R��5X� Sj��X�?E��H�;=��B2r&!'�]����E��xɅ(�Z�Tgߟ��%�� �����Gu�W���Ga,�?��a<���0��x�a<���0��x�a<���0��x�a<���0��x�a<���0��x�>�T�� � 