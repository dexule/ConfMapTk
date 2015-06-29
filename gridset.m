classdef gridset < optset
%GRIDSET holds grid preferences.

% Copyright 2015 the ConfMapTk project developers. See the COPYRIGHT
% file at the top-level directory of this distribution and at
% https://github.com/ehkropf/ConfMapTk.
%
% This file is part of ConfMapTk. It is subject to the license terms in
% the LICENSE file found in the top-level directory of this distribution
% and at https://github.com/ehkropf/ConfMapTk.  No part of ConfMapTk,
% including this file, may be copied, modified, propagated, or distributed
% except according to the terms contained in the LICENSE file.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the LICENSE
% file.

properties
    gridType
    numRadialLines
    numCircularLines
    numLevels
end

properties(Access=protected)
    proplist = { ...
        'gridType', 'polar', [], '[ string {polar} | carleson ]'
        'numRadialLines', 20, [], '[ positive integer {20} ]'
        'numCircularLines', 5, [], '[ positive integer {5} ]'
        'numLevels', 5, [], '[ positive integer {5} ]'
    };
end

methods
    function opts = gridset(varargin)
        opts = opts@optset(varargin{:});
    end
    
    function opts = set.gridType(opts, value)
        opts.gridType = lower(value);
    end
end

end
