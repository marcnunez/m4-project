function [Pproj, Xproj] = factorization_method(x)
%FACTORIZATION_METHOD computes a projective reconstruction with the 
% factorization method of Sturm and Triggs '1996
% This function returns an estimate of:
%       Pproj: 3*Ncam x 4 matrix containing the camera matrices
%       Xproj: 4 x Npoints matrix of homogeneous coordinates of 3D points
% 
    
    d_old = 100;
    maxIter = 1000;
    
    m = size(x, 1) / 3;
    n = size(x, 2);
    
    lambdas = ones(m, n);
    
    
    H = cell(1, m);
    for i=1:m
        r = i*3-2:i*3;
        [x(r, :), H{i}] = normalise2dpts(x(r, :));
    end
    
    for iteration = 1:maxIter

        % Create the design matrix M.
        lambdas_mat = kron(lambdas, [1 1 1]');
        M = lambdas_mat.*x;
    
        % Rank 4
        [U,D,V] = svd(M);
        D4 = D(1:4,1:4);
        U4 = U(:,1:4);
        V4 = V(:,1:4);
        
        Pproj = U4*D4;
        Xproj = V4';
        
        % As a convergence criterion you may compute the Euclidean
        % distance (d) between data points and projected points in both images 
        % and stop when (abs(d - d_old)/d) < 0.1 where d_old is the distance
        % in the previous iteration.
        d = sqrt(sum(sum((M - (Pproj*Xproj)).^2)));
        if (abs(d - d_old)/d) < 0.1
            break;
        end
        d_old = d;
        
        M_rec = Pproj*Xproj;
        lambdas = M_rec(3:3:3*m, :);
    end
    
    for i=1:m
        r = i*3-2:i*3;
        Pproj(r, :) = H{i} \ Pproj(r, :);
    end
end

