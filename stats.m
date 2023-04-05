A_rand = A(randperm(length(A)));
ave1 = mean(A_rand(1:27));
ave2 = mean(A_rand(28:47));
dif = ave1 - ave2;