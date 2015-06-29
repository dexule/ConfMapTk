classdef ellipse < closedcurve
% ELLIPSE class represents a parameterized ellipse.

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
  a = 1
  b = 1
  r = 0
end

properties(Access=protected)
  eVar
end

methods
  function E = ellipse(varargin)
    if nargin == 1 % epsilon case
      e = varargin{1};
      if e < 0 || 1 <= e
        error('CMT:InvalidArgument', ...
              'Single argument must satisfy 0 <= epsilon < 1.')
      end
      
      E.a = 1 + e;
      E.b = 1 - e;
      E.eVar = e;
    elseif nargin >= 2
      if nargin > 3
        error('CMT:InvalidArgument', 'Too many arguments.')
      end
      [E.a, E.b] = varargin{1:2};
      if abs(E.a + E.b - 2) < 10*eps(2)
        E.eVar = E.a - 1;
      end
      if nargin > 2
        E.r = varargin{3};
      end
    end
  end
  
  function disp(E)
    fprintf('parameterized ellipse:\n\n')
    fprintf('\tmajor axis   %f\n', E.a)
    fprintf('\tminor axis   %f\n', E.b)
    fprintf('\teccentricity %f\n', E.a/E.b)
    if ~isempty(E.eVar)
      fprintf('\tepsilon      %f\n', E.eVar)
    end
    fprintf('\n')
  end
  
  function z = point(E, t)
    t = modparam(E, t)*2*pi;
    z = E.a*cos(t) + 1i*E.b*sin(t);
    if E.r
      z = z*exp(1i*E.r);
    end
  end
  
  function zt = tangent(E, t)
    t = modparam(E, t)*2*pi;
    zt = (-E.a*sin(t) + 1i*E.b*cos(t))*2*pi;
    if E.r
      zt = zt.*exp(1i*E.r);
    end
  end
  
  function th = theta_exact(E, t)
    % Boundary correspondence of conformal map to circle.
    % Exact to machine precision.
    % See Henrici, vol. 3, p. 391, equation for theta at bottom of page.
    if isempty(E.eVar)
      error('Must define ellipse with epsilon parameter.')
    end
    if E.eVar > 0.95
      warning('This is not accurate for epsilon > 0.95.')
    end
    
    t = modparam(E, t)*2*pi;
    
    % ellipse term magnitude function
    emf = @(m, e) e.^m./(1 + e.^(2*m))./m;
    % term function
    termfun = @(t, m) (-1).^m.*emf(m, E.eVar).*sin(2*m.*t);
    
    % Keep adding terms, 20 at a time, until too tiny to make a change. Good
    % up to about e = 0.95.
    th = t(:);
    for k = 1:60
      m = (k-1)*20 + (1:20);
      th = th + 2*sum(bsxfun(termfun, t, m), 2);
      if all(emf(m(end), E.eVar) < eps(th))
        break
      end
    end
    th = reshape(th, size(t));
  end
end

end
