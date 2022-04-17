dx2 = 1;

%% Finite Difference Method

G = sparse(nx*ny);
F = zeros(nx*ny,1);
V_0 = 1; %V

for i = 1:nx
    for y = 1:ny

        n = y + (i-1)*ny; % node mapping

        if i == 1 % left side = V_0

            G(n,n) = 1;
            F(n) = V_0;

        elseif i == nx % right side = 0V

            G(n,n) = 1;
            F(n) = V_0;
            
        elseif y == ny % top side = insulated

            G(n,n) = 1;
            F(n) = 0;

        elseif y == 1 % bottom side = insulated

            G(n,n) = 1;
            F(n) = 0;

        else % middle node
            
            nxm = y + (i-2)*ny;
            nxp = y + i*ny;
            nym = (y-1) + (i-1)*ny;
            nyp = (y+1) + (i-1)*ny;
            
            % middle nodes in G, based on the sum of four neighbour cells
            G(n,n) = -4;
            G(n,nxm) = 1;
            G(n,nxp) = 1;
            G(n,nym) = 1;
            G(n,nyp) = 1;

        end

    end
end

V = G\F;

% Map voltages back into a matrix

Vmap = zeros(nx,ny); % initialize matrix
n = 0; % clear/reset node index n

for i = 1:nx
    for y = 1:ny

        n = y + (i-1)*ny;
        Vmap(i,y) = V(n);

    end
end

% Mapping needs to be inverted to set the sides of the matrix to match the
% appropriate BCs
VmapInv = Vmap';

%% Analytical Series

V_ana = zeros(L,W);
a = W;
b = L/2;
K = (4*V_0/pi);

x = linspace(-b,b,nx);
y = linspace(0,a,ny);

for n = 1:2:200
    
    for i = 1:L
        for j = 1:W
            V_ana(i,j) = V_ana(i,j) + ((K/n) * ((cosh(n*pi*x(i)/a)) / (cosh(n*pi*b/a))) * (sin(n*pi*y(j)/a)));
        end
    end
    figure(2)
    subplot(2,1,1); surf(VmapInv) % plot surface
    title('Finite Difference Method')
    xlabel('Region Length')
    ylabel('Region Width')
    subplot(2,1,2); surf(V_ana')
    title('Numerical Calculation')
    xlabel('Region Length')
    ylabel('Region Width')
end
    




