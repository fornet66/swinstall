
cd zh_CN/RPMS
yum localinstall *.rpm
cd /opt/openoffice4/program
nohup soffice -headless -nologo -accept="socket,host=127.0.0.1,port=8100;urp;StarOffice.ServiceManager" -nofirststartwizard &

