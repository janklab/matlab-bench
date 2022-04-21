function out = display_system_info
%DISPLAY_SYSTEM_INFO Display info about system this is running on

% TODO: Detect when running in VM host

javaProps = javaMethod('getProperties', 'java.lang.System');
javaVersion = char(javaProps.get('java.version'));

localhostAddress = javaMethod('getLocalHost', 'java.net.InetAddress');
hostname = char(localhostAddress.getHostName());
hostname = regexprep(hostname, '\..*', '');
osDescr = [char(javaProps.get('os.name')) ' ' char(javaProps.get('os.version'))];
systemExtra = '';

out = struct;

switch computer
    case {'MACI64'}
        cpuModel = sysctl_prop('machdep.cpu.brand_string');
        nCpuCores = str2double(sysctl_prop('machdep.cpu.core_count'));
        %cpuCacheSize = str2double(sysctl_prop('hw.l3cachesize')) / (2^20);
        memSizeGB = str2double(sysctl_prop('hw.memsize')) / 2^30;
        cpuDescr = sprintf('%s, %d cores', cpuModel, nCpuCores);
    case {'PCWIN','PCWIN64'}
        cpuDescr = strrep(getenv('PROCESSOR_IDENTIFIER'), ', GenuineIntel', '');
        try
            cpuVendorId = winqueryreg('HKEY_LOCAL_MACHINE',...
                'HARDWARE\DESCRIPTION\System\CentralProcessor\0', 'ProcessorNameString');
            cpuDescr = cpuVendorId;
            sysName = winqueryreg('HKEY_LOCAL_MACHINE', 'HARDWARE\DESCRIPTION\System\BIOS',...
                'SystemProductName');
            systemExtra = sysName;
        catch
            % quash
        end
        w64Arch = getenv('PROCESSOR_ARCHITEW6432');
        if ~isempty(w64Arch)
            osDescr = [osDescr ' (WoW64)'];
        end
        memSizeGB = memsize_using_memory_fcn();
    case {'GLNXA64'}
        %TODO: Linux support with procfs
        [~,cpuDescr] = system('grep "model name" /proc/cpuinfo | head -1');
        cpuDescr = chomp(regexprep(cpuDescr, '.*?: ', ''));
        [~,memSizeDescr] = system('grep "MemTotal" /proc/meminfo | head -1');
        [match,tok] = regexp(memSizeDescr, '(\d+) kB', 'match', 'tokens');
        if ~isempty(match)
            memK = str2double(tok{1}{1});
            memSizeGB = memK / 2^10;
        else
            memSizeGB = NaN;
        end
        [~,kernelVer] = system('uname -v');
        systemExtra = chomp(kernelVer);
    otherwise
        % This shouldn't happen, but just in case...
        cpuDescr = '???';
        memSizeGB = NaN;
end


% Be terse
cpuDescr = strrep(cpuDescr, 'Intel(R) Core(TM) ', 'Core ');

miscStr = '';
if isdeployed
    miscStr = [miscStr ' DEPLOYED'];
end
%fprintf('Arch: %-8s  Release: %-s  %s\n', computer, ['R' version('-release')], miscStr);
if is_octave
  appName = 'Octave';
else
  appName = 'Matlab';
end
out.OsDescr = osDescr;
out.CpuDescr = cpuDescr;
out.MemSizeGB = memSizeGB;
out.SystemExtra = systemExtra;
if nargout == 0
    fprintf('%s %s on %s %s \n', appName, ['R' version('-release')], computer, miscStr);
    fprintf('%s %s / Java %s on %s %s (%s) \n', appName, version, javaVersion,...
        computer, osDescr, hostname);
    if ~isempty(systemExtra)
        systemExtra = sprintf('(%s)', systemExtra);
    end
    fprintf('Machine: %s, %d GB RAM %s\n', cpuDescr, memSizeGB, systemExtra);
    clear out
end

end

function out = memsize_using_memory_fcn()
%MEMSIZE_USING_MEMORY_FCN Get memory size using memory()
%
% Only works on platforms that support memory(). OS X does not.
% Returns number of gigabytes as string.
[~,mb] = memory();
out = mb.PhysicalMemory.Total / 2^30;
end

function out = chomp(str)
%CHOMP Remove trailing newline from string
out = regexprep(str, '\r?\n$', '');
end

function out = sysctl_prop(name)
%SYSCTL_PROP Get a sysctl property (OS X) by name as string
[status,str] = system(['sysctl -n ' name]);
if status ~= 0
    warning('Failed getting sysctl property %s: %s', name, str);
    out = '???';
else
    out = chomp(str);
end
end
