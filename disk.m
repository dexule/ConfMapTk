classdef disk < region
% DISK is a region bounded by a circle.

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

methods
    function D = disk(center, radius)
        badargs = false;
        switch nargin
            case 0
                C = [];

            case 1
                if isa(center, 'disk')
                    C = center.outerboundary;
                elseif isa(center, 'double') && numel(center) == 3
                    C = circle(center);
                elseif isa(center, 'circle') && ~isinf(center)
                    C = center;
                else
                    badargs = true;
                end

            case 2
                if isa(center, 'double') && isa(radius, 'double') ...
                        && numel(center) == 1 && numel(radius) == 1
                    C = circle(center, radius);
                else
                    badargs = true;
                end

            otherwise
                badargs = true;
        end
        if badargs
            error('CMT:InvalidArgument', ...
                'Expected 3 points or a center and radius.')
        end

        if isempty(C)
            supargs = {};
        else
            supargs = {C};
        end
        
        D = D@region(supargs{:});
        get(D, gridset);
    end

    function gd = carlesonGrid(D, opts)
        % Generate a basic Carleson grid. Default 5 levels.

        levels = opts.numLevels;

        nu = 32; % Base radial line number.
        r = 0.6; % Base circle radius.

        gc = cell(1 + levels + 2^(levels-1)*nu, 1);

        % Level 0 circle.
        ncp = 200;
        gc{1} = r*exp(2i*pi*(0:ncp-1)'/(ncp-1));

        % Base number of radial line points per unit length.
        ppul = 200;

        idx = 1;
        for j = 1:levels
            if j > 1
                nuj = 2^(j-2)*nu;
            else
                nuj = nu;
            end
            ncr = ceil(j*ppul*(1 - r));
            rln = linspace(r, 1 - 1e-8, ncr)';
            dt = 2*pi/nuj;
            off = (j > 1)*dt/2;
            for k = 1:nuj
                gc{idx + k} = rln*exp(1i*(off + (k-1)*dt));
            end

            idx = idx + nuj + 1;
            r = (1 + r)/2;
            np = (j+1)*ncp;
            gc{idx} = r*exp(2i*pi*(0:np-1)'/(np-1));
        end

        gd = gridcurves(gc);
        c = center(outer(D));
        r = radius(outer(D));
        if ~(c == 0 && r == 1)
            gd = c + r*gd;
        end
    end
    
    function gd = grid(D, varargin)
        opts = get(D);
        opts = set(opts, varargin{:});
        
        switch opts.gridType
            case 'polar'
                gd = polarGrid(D, opts);
                
            case 'carleson'
                gd = carlesonGrid(D, opts);
                
            otherwise
                error('CMT:NotDefined', ...
                    'Grid type "%s" not recognized.', type)
        end
    end


    function tf = hasgrid(~)
        tf = true;
    end
    
    function gd = polarGrid(D, opts)
        nrad = opts.numRadialLines;
        ncirc = opts.numCircularLines;
        
        npt = 200;
        c = center(outer(D));
        r = radius(outer(D));

        curves = cell(nrad + ncirc, 1);
        zg = (1:npt)'/(npt+1);
        for k = 1:nrad
            curves{k} = c + r*exp(2i*pi*(k-1)/nrad)*zg;
        end
        zg = exp(2i*pi*(0:npt-1)'/(npt-1));
        for k = 1:ncirc
            curves{nrad + k} = c + r*k/(ncirc+1)*zg;
        end

        gd = gridcurves(curves);
    end
end

end
