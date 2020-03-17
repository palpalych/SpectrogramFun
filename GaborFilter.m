function [g] = GaborFilter(t, scaling, center)
%GABOR Apply the gabor filter at time(s) t
%   The Gabor filter is a Gaussian centered at a particular point
%   with some given scaling. This function is meant to work for
%   a single particular time or a vector of times
g=exp(-scaling.*(t-center).^2); 
end