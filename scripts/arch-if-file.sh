echo Interface=eth0
echo Connection=ethernet
echo IP=static
echo Address=\(\'$1/24\'\)
echo Gateway=\'$2\'
echo Broadcast=\'$3\'
echo DNS=\(\'8.8.8.8\'\)

echo IP6=static
echo Address6=\($4/$6\)
echo Gateway6=\'$5\'
