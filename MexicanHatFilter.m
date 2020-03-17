function [m] = MexicanHatFilter(t, scaling, center)
%MEXICANHATFILTER Apply the mexican hat filter at time(s) t
m=(1-((t-center)/scaling).^2).*exp(-(((t-center)/scaling).^2)/2); 
end