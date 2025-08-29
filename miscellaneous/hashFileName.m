function filename = hashFileName(Args)
    hash_input = '';
    for i = 1:length(Args.DataCheckArgs)
        key = Args.DataCheckArgs{i};
        val = Args.(key);
        if isnumeric(val)
            valStr = mat2str(val);
        elseif ischar(val)
            valStr = val;
        else
            error(['Unsupported argument type: ' key]);
        end
        hash_input = [hash_input '_'  valStr];

    end
    hashString = javaHash(hash_input, 'SHA-256');

    % Create final short and unique filename
    filename = sprintf('%s_%s.mat', Args.classname, hashString(1:16));  % Shorten to 16 chars
