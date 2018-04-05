% This function computes the fisher vector representation of a set of vectors
% See "Fisher kernels on visual vocabularies for image categorization"
%     by F. Perronnin and C. Dance, CVPR'2007
% 
% Usage: 
%   fishervector = yael_fisher_elem (v, w, mu, sigma)
%   fishervector = yael_fisher_elem (v, w, mu, sigma, 'opt1', 'opt2', ...)
%
% where
%   v is the set of descriptors to describe by the Fisher Kernel representation
%   w, mu and sigma are the parameters of the mixture (learned by, e.g., yael_gmm)
%
% The difference with function yael_fisher is that it returns the output for each Fisher vector
%
% Note : The GMM estimation always assume a diagonal-form matrix. 
%        Use a PCA rotation on input vectors to be closer to this assumption. 
%
% By default, only the derivatives associated with the mu component are computed
%
% Options:
%   'weights'   includes the mixture weights in the representation
%   'sigma'     includes the terms associated with variance
%   'nomu'      do not compute the terms associated with mean
%   'nonorm'    do not normalize the fisher vector
%   'verbose'   
