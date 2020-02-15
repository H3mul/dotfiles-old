cd / # THIS CD IS IMPORTANT THE FOLLOWING LONG COMMAND IS RUN FROM /
backupfile="backup.$(date "+%Y.%m.%d-%H.%M.%S").tar.gz"

tar -cvpzf /backups/$backupfile \
--exclude=/backups \
--exclude=/proc \
--exclude=/tmp \
--exclude=/mnt \
--exclude=/dev \
--exclude=/sys \
--exclude=/run \
--exclude=/media \
/
