function [s] = StepFilter(t, scaling, center)
%STEPFILTER Returns 1 in a range defined by center and scaling, 0
%everywhere else
s = double(t >= (center - scaling/2) & t <= (center + scaling/2));
end