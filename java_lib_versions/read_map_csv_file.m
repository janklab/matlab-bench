function out = read_map_csv_file(fileName, nCols)
%READ_MAP_CSV_FILE Read a CSV-formatted map file in our directory
myDir = fileparts(mfilename('fullpath'));
libMapFile = fullfile(myDir, fileName);
fid = fopen(libMapFile);
c = textscan(fid, repmat('%q', [1 nCols]), 'Delimiter',',');
fclose(fid);
c = cat(2, c{:}); % works because it's all string data
out = lametable(c(1,:), c(2:end,:));
end



