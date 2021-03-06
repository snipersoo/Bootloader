#!/usr/bin/env bash

[ -n "$GIT_SUBMODULES_ARE_EVIL" ] && {
    # GIT_SUBMODULES_ARE_EVIL is set, meaning user doesn't want submodules
    echo "Skipping submodules."
    exit 0
}

GITSTATUS=$(git status)

function check_git_submodule {

if [ -d $1 ];
	then
	SUBMODULE_STATUS=$(git submodule summary "$1")
	STATUSRETVAL=$(echo $SUBMODULE_STATUS | grep -A20 -i "$1" | grep "<")
	if [ -z "$STATUSRETVAL" ]; then
		echo "Checked $1 submodule, correct version found"
	else
		echo -e "\033[31mChecked $1 submodule, ACTION REQUIRED:\033[0m"
		echo ""
		echo -e "New commits required:"
		echo -e "$SUBMODULE_STATUS"
		echo ""
		echo ""
		echo -e " *******************************************************************************"
		echo -e " *   \033[31mIF YOU DID NOT CHANGE THIS FILE (OR YOU DON'T KNOW WHAT A SUBMODULE IS):\033[0m  *"
		echo -e " *   \033[31mHit 'u' and <ENTER> to update ALL submodules and resolve this.\033[0m            *"
		echo -e " *   (performs \033[94mgit submodule update --init --recursive\033[0m)                        *"
		echo -e " *******************************************************************************"
		echo ""
		echo ""
		echo -e "   Only for EXPERTS:"
		echo -e "   $1 submodule is not in the recommended version."
		echo -e "   Hit 'y' and <ENTER> to continue the build with this version. Hit <ENTER> to resolve manually."
		echo -e "   Use \033[94mgit add $1 && git commit -m 'Updated $1'\033[0m to choose this version (careful!)"
		echo ""
		read user_cmd
		if [ "$user_cmd" == "y" ]
		then
			echo "Continuing build with manually overridden submodule.."
		else
			if [ "$user_cmd" == "u" ]
			then
				git submodule update --init --recursive
				echo "Submodule fixed, continuing build.."
			else
				echo "Build aborted."
				exit 1
			fi
		fi
	fi
else
	git submodule update --init --recursive;
	git submodule update;
fi

}

check_git_submodule libopencm3
check_git_submodule lib/kinetis/NXP_Kinetis_Bootloader_2_0_0

exit 0
