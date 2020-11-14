#!/bin/bash

base_dir="$(dirname "$(readlink -f "$0")")"
pushd "$base_dir" >/dev/null

PREFIX="${PREFIX:-/usr/local}"
BINDIR="${BINDIR:-$PREFIX/bin}"
DATAROOTDIR="${DATAROOTDIR:-$PREFIX/share}"
DOCDIR="${DOCDIR:-$DATAROOTDIR/doc}"
MANDIR="${MANDIR:-$DATAROOTDIR/man}"
ICONDIR="${ICONDIR:-$DATAROOTDIR/icons}"
DESKDIR="${DESKDIR:-$DATAROOTDIR/applications}"

#install bin
for file in bin/syncthing*; do
	if [[ -f "$file" ]]; then
		dest="$BINDIR/$(basename "$file")"
		printf "Installing \"$file\" to \"$dest\"\n"
		#perms: 755
		install -C -m 755 -D "$file" "$dest" || echo "   Failed to install." 1>&2
	fi
done

#install man pages
for num in {1..8}; do
	for file in man/*.$num; do
		if [[ -f "$file" ]]; then
			#mkdir -m 664 -p $man_dir/man$num
			dest="$MANDIR/man$num/$(basename "$file")"
			printf "Installing \"$file\" to \"$dest\"\n"
			#perms: 644
			install -C -m 644 -D "$file" "$dest" || echo "   Failed to install." 1>&2
		fi
	done
done

#install docs
for file in AUTHORS LICENSE README.md; do
	if [[ -f "$file" ]]; then
		name="$(basename "$file" ".md")"
		dest="$DOCDIR/syncthing/$name.txt"
		printf "Installing \"./$file\" to \"$DOCDIR/syncthing/$name.txt\"\n"
		#perms: 644
		install -C -m 644 -D "$file" "$dest" || echo "   Failed to install." 1>&2
	fi
done

#install icons
for logo in assets/logo-[0-9]*.png; do
	if [[ "$(basename "$logo")" =~ ^logo-([0-9]+)\.png$ ]]; then
		size=${BASH_REMATCH[1]}
		dest="$ICONDIR/hicolor/${size}x${size}/apps/syncthing.png"
		printf "Installing \"$logo\" to \"$dest\"\n"
		#perms: 644
		install -C -m 644 -D "$file" "$dest" || echo "   Failed to install." 1>&2
	fi
done

if [[ -f "assets/logo-only.svg" ]]; then
	dest="$ICONDIR/hicolor/scalable/apps/syncthing.svg"
	printf "Installing \"assets/logo-only.svg\" to \"$dest\"\n"
	#perms: 644
	install -C -m 644 -D "$file" "$dest" || echo "   Failed to install." 1>&2
fi

#install .desktop files
for file in etc/linux-desktop/syncthing-*.desktop; do
	if [[ -f "$file" ]]; then
		dest="$DESKDIR/$(basename "$file")"
		printf "Installing \"$file\" to \"$dest\"\n"
		install -C -m 644 -D "$file" "$dest" || echo "   Failed to install." 1>&2
	fi
done

#update icon cache
printf "\nUpdating icon cache\n"
gtk-update-icon-cache

printf "\nUpdating mandb\n"
mandb "$MANDIR"

printf "\nUpdating desktop database\n"
update-desktop-database "$DESKDIR"

popd >/dev/null
