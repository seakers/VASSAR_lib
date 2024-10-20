function [bool,fit] = SEL_Iridium_archs_that_fit(archs,mask,MAX)
fit = sum(archs(:,logical(mask)),2);
bool = fit<=MAX;
end