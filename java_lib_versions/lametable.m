classdef lametable
    %LAMETABLE A simple table of string data
    %
    % This holds a table of data whose columns are all cellstrs.
    %
    % I was going to name this class "simpletable", but when you say that aloud, it
    % sounds too much like "symbol table", which means something else entirely.
    
    properties
        colnames = {};
        data = {};
    end
    
    methods
        
        function obj = lametable(varargin)
        %LAMETABLE Construct a lametable
        %
        % obj = lametable()
        % obj = lametable(struct)
        % obj = lametable(colnames, data)
        if nargin == 0
            
        elseif nargin == 1
            if isstruct(varargin{1})
                s = varargin{1};
                obj.data = struct2cell(s(:))';
                obj.colnames = fieldnames(s);
            else
                error('Invalid arguments');
            end
        elseif nargin == 2
            [obj.colnames, obj.data] = varargin{:};
        else
            error('Invalid arguments');
        end
        end
        
        function out = joinupdate(tblA, keyCols, updateColsA, tblB, refColsB)
        %JOINUPDATE Update a table based on a join to another table
        % This is a hackish implementation of an SQL-style JOIN operation
        % Assumes keys only occur once in tblB
        [~,ixUpdateColsA] = ismember(updateColsA, tblA.colnames);
        [~,ixRefColsB] = ismember(refColsB, tblB.colnames);
        
        keys1 = makesinglekey(project(tblA,keyCols));
        keys2 = makesinglekey(project(tblB,keyCols));
        if numel(unique(keys2)) < numel(keys2)
            error('Non-unique key colums in tblB');
        end
        [tf,loc] = ismember(keys1, keys2);
        out = tblA;
        out.data(tf,ixUpdateColsA) = tblB.data(loc(tf),ixRefColsB);
        end
        
        function out = distinct(tbl)
        %DISTINCT SQL-style DISTINCT on obj, keeps only unique row values
        
        % Gotta make keys because unique(...,'rows') doesn't work on cellstrs
        keys = makesinglekey(tbl);
        [~,ixDistinctRows] = unique(keys);
        out = tbl;
        out.data = tbl.data(ixDistinctRows,:);
        end
        
        function out = project(tbl, cols)
        %PROJECT Project obj to named columns
        [~,ixCols] = ismember(cols, tbl.colnames);
        out = lametable;
        out.colnames = cols;
        out.data = tbl.data(:,ixCols);
        end
        
        function out = restrict(tbl, ix)
        %RESTRICT RESTRICT on our table structure
        out = tbl;
        out.data = tbl.data(ix,:);
        end
        
        function out = makesinglekey(obj, colNames)
        %MAKESINGLEKEY Make a single-string key out of multi-column keys
        %
        % Returns cellstr that serves as proxy keys for obj's rows
        if nargin > 1
            obj = project(obj, colNames);
        end
        c = obj.data;
        out = c(:,1);
        for i = 2:size(c,2)
            out = strcat(out, '::', c(:,i));
        end
        end
        
        function out = pullupfields(obj, fields)
        %PULLUPFIELDS Reorder named columns to front of table
        out = project(obj, [obj.colnames setdiff(obj.colnames, fields, 'stable')]);
        end
        
    end
end

