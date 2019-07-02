classdef BatchErrorLog < handle
    %BATCHERRORLOG
    
    properties (Access = private)
        errors
    end
        
    methods
        function obj = BatchErrorLog()
            %BATCHERRORLOG Construct batch error logger.
            
            obj.errors = obj.pack({}, {});
        end
        
        function [] = log(obj, fileWithError, errorThrown)
            %LOG Log error thrown while processing a file.
            %   
            %   In
            %   fileWithError (char): abs path to file that was being
            %   processed when error thrown
            %   
            %   errorThrown (MException): the error thrown
            
            narginchk(3, 3);
            
            validateattributes(fileWithError, {'char'}, {'nonempty', 'vector'}, mfilename, 'fileWithError');
            validateattributes(errorThrown, {'MException'}, {'nonempty', 'scalar'}, mfilename, 'errorThrown');
            
            obj.errors(end+1) = obj.pack(fileWithError, errorThrown);
        end
        
        function logged = loggedErrors(obj)
            %ERRORSLOGGED Return whether any errors were logged.
            %   
            %   Out
            %   logged (logical): whether errors were logged
            
            narginchk(1, 1);
            
            logged = ~isempty(obj.errors);
        end
        
        function summary = summarize(obj)
            %SUMMARIZE Return list of files that threw errors while being
            %processed.
            %   
            %   Out
            %   summary (char): Formatted list of files
            
            narginchk(1, 1);
            
            files = {obj.errors.file};
            files = strjoin(files, '\n');
            
            summaryFormat = 'Errors detected while processing the following files:\n%s';
            summary = sprintf(summaryFormat, files);
        end
        
        function filePath = save(obj, destination)
            %SAVE Write out log to the destination folder.
            %
            %Log file name foramat: batchErrors.yyyymmdd.HHMMSS.txt
            %   
            %   In
            %   destination (char): log file's destination
            %   
            %   Out
            %   filePath (char): path to log file
            
            validateattributes(destination, {'char'}, {'nonempty', 'vector'}, mfilename, 'destination');
            
            assert(exist(destination, 'dir') == 7,...
                'dynamical:invalidPath',...
                '%s does not exist', destination);
            
            rightNow = datestr(now, 'yyyymmdd.HHMMSS');
            fileName = sprintf('batchErrors.%s.txt', rightNow);
            filePath = fullfile(destination, fileName);
            
            fId = fopen(filePath, 'w');
            fIdCleanup = onCleanup(@() fclose(fId));
            
            if fId == -1
                warning('Unable to open %s\nCannot save error log', filePath);
                filePath = '';
                return;
            end
            
            for e = obj.errors
                fileWithError = e.file;
                errorThrown = e.error.getReport('extended', 'hyperlinks', 'off');
                fprintf(fId, '%s\n%s\n\n', fileWithError, errorThrown);
            end
        end
    end
    
    methods (Access = private)
        function packed = pack(~, file, error)
            %PACK Pack file path and exception object into struct.
            %   
            %   In
            %   file (char): file with error
            %   
            %   error (MException): error thrown
            %   
            %   Out
            %   packed (struct): file and error bundled together
            %   
            %       packed.file = file
            %       packed.error = error
            
            narginchk(3, 3);
            
            packed = struct('file', file, 'error', error);
        end
    end
end

