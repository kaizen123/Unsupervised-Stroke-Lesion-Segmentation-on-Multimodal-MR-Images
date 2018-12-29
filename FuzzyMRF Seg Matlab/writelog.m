function [] = writelog(msg)
%WRITELOG 
%   writing running status into .txt
global RunTime;
logpath = strcat(strcat(pwd(),'\'),strcat(RunTime, '.txt'));
fid = fopen(logpath, 'a');
fprintf(fid,'%s : ',datestr(now,30));
fprintf(fid,'%s\n',msg);
fclose(fid);

end

