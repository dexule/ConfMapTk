classdef closedcurve
% CLOSEDCURVE abstract base class for simple planar Jordan curves.

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
  cornerList                % Placeholder.
  paramLength = 1           % Parameter length.
end

methods
  % Just use default constructor; nothing to do right now on construction.
  
  function box = boundbox(C)
    % Return bounding box for curve using evenly spaced points.
    t = C.paramLength*(0:199)'/200;
    box = cmt.boundbox(point(C, t));
  end
  
  function varargout = corner(C, varargin)
    % I'm honestly not quite sure about the usage of this, it will probably
    % change drastically in the future. Haven't found it being used yet in any
    % of Toby's code examples. -- EK
    % Other than being set in the polygon constructor. -- EK
    v = C.cornerList;
    
    % Classes of input args?
    inclass = cellfun(@class, varargin, 'uniformoutput', false);
    
    % Did we get an index?
    j = find(strcmp('double', inclass));
    if ~isempty(j)
      v = v(varargin{j});
    end
    
    % Field selection?
    j = find(strcmp('char', inclass));
    if ~isempty(j)
      varargout{1} = cat(1, v.(varargin{j}));
    else
      if nargout == 3
        t = cat(1, v.param);
        z = cat(1, v.point);
        alpha = cat(1, v.alpha);
        varargout = {t, z, alpha};
      else
        varargout{1} = v;
      end
    end
  end
  
  function C = ctranspose(C)
    C = cinvcurve(C);
  end
  
  function display(C)
    fprintf('\n%s =\n', inputname(1))
    disp(C)
  end
  
  function R = exterior(C)
      % EXTERIOR creates an exterior region bounded by curve.
      %
      % R = exterior(C)
      % Creates exterior region R bounded by closed curve C.
      %
      % See also closedcurve, region.
      
      if ~isa(C, 'closedcurve')
          error('CMT:InvalidArgument', ...
              'Function argument must be a closed curve.')
      end
      
      R = region(C, 'exteriorto');
  end
  
  function out = fill(C, varargin)
    washold = ishold;
    
    % Rely on adaptplot or overloaded plot to get curve "right".
    hold on
    h = plot(C);
    z = complex(get(h, 'xdata'), get(h, 'ydata'));
    delete(h)
    
    args = cmtplot.fillargs;
    h = fill(real(z), imag(z), args{:}, varargin{:});
    
    if ~washold
      hold off
    end
    
    if nargout
      out = h;
    end
  end
  
  function R = interior(C)
      % INTERIOR creates a bounded region with boundary C.
      %
      % R = exterior(C)
      % Creates interior region R bounded by closed curve C.
      %
      % See also closedcurve, region.
      
      if ~isa(C, 'closedcurve')
          error('CMT:InvalidArgument', ...
              'Function argument must be a closed curve.')
      end
      
      R = region(C);
  end
  
  function n = length(C)
    % Curve parameter length.
    n = C.paramLength;
  end
  
  function t = modparam(C, t)
    % Ensures parameter satisfies 0 <= t < C.paramLength.
    if any(t < 0 | 1 <= C.paramLength)
      t = mod(t, C.paramLength);
    end
  end
  
  function out = plot(C, varargin)
    % Plot curve in the plane.
    washold = ishold;
    newplot
    
    h = plotCurve(C);
    [cargs, pargs] = cmtplot.closedcurveArgs(varargin{:});
    set(h, pargs{:}, cargs{:});

    if ~washold
      axis(plotbox(C, 1.1));
      set(gca, 'dataaspectratio', [1 1 1])
      hold off
    end
    
    if nargout > 0
      out = h;
    end
  end
    
  function box = plotbox(C, scale)
    % Return plot box for curve using evenly spaced points.
    %
    % See also plotbox.
    
    if nargin < 2
      scale = [];
    end
    t = C.paramLength*(0:199)'/200;
    box = cmt.plotbox(point(C, t), scale);
  end

  function out = rsplot(C, varargin)
    % Plot curve on the Riemann sphere.
    washold = ishold;
    
    % Draw Riemann shpere if not there.
    if isempty(findobj(gca, 'tag','CMT:RiemannSphere')) || ~washold
      [xs, ys, zs] = sphere(36);
      mesh(0.995*xs, 0.995*ys, 0.995*zs, 'edgecolor', .85*[1 1 1], ...
           'tag', 'CMT:RiemannSphere')
      hold on
    end
    
    % Draw on the sphere.
    function x = rspoint(t)
      z = point(C, t);
      [x1, x2, x3] = c2rs(z);
      x = [x1, x2, x3];
    end
    h = adaptplot(@rspoint, [0, C.paramLength]);
    set(h, varargin{:});
    
    if ~washold
      hold off
    end
    axis equal
    
    if nargout > 0
      out = h;
    end
  end
  
  function z = subsref(C, S)
    % Equate C(t) with point(C, t). Fallback to builtin subsref otherwise.
    if numel(S) == 1 && strcmp(S.type, '()')
      if numel(S.subs) == 1
        z = point(C, S.subs{1});
        return
      else
        error('Object only takes single parenthised subscript.')
      end
    end
    
    z = builtin('subsref', C, S);
  end
  
  function xy = xypoint(C, t)
      z = point(C, t);
      xy = [real(z), imag(z)];
  end
end

methods(Abstract=true)
  z = point(C, t)
  z = tangent(C, t)
end

methods(Hidden)
  function h = plotCurve(C, varargin)
    h = adaptplot(@(t) xypoint(C, t), [0, C.paramLength]);
  end
end

methods (Access=private)
    function [x1, x2, x3] = c2rs(z)
        % C2RS Cartesian complex coordinate to Riemann sphere projection.
        
        % This file is a part of the CMToolbox.
        % It is licensed under the BSD 3-clause license.
        % (See the file LICENSE.bsd in the top level directory of this distribution..)
        
        % Copyright Toby Driscoll, 2014.
        
        theta = angle(z);
        absz = abs(z);
        phi = atan2(absz.^2 - 1, 2*abs(z));
        phi(isinf(z)) = pi/2;
        [x1, x2, x3] = sph2cart(theta, phi, ones(size(theta)));
        
    end
end

end
