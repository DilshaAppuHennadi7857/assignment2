boxLeft = 0.45;
boxRight = 0.55;
boxBottom = 0.70;
boxTop = 0.30;

condHigh = 1;
condLow = 10e-2;

cMap = zeros(L,W);

for i = 1:L
    
    for j = 1:W
        
        if ((i>=boxLeft*L) && (i<=boxRight*L) && (((j>=boxBottom*W) && (j<=W)) || ((j<=boxTop*W) && (j>=0))))
            cMap(i,j) = condLow;
        else
            cMap(i,j) = condHigh;
        end
        
    end
    
end

G = sparse(L*W);
F = zeros(L*W,1);
V_0 = 1; %V

for i = 1:L
    for j = 1:W

        n = j + (i-1)*W; % node mapping

        if i == 1 % left side = V_0

            G(n,n) = 1;
            F(n) = V_0;

        elseif i == L % right side = 0V

            G(n,n) = 1;
            F(n) = 0;
            
        elseif j == W % top side = insulated

            % only three resistors:
            % n(x-1,y), n(x+1,y), n(x,y-1)

            nxm = j + (i-2)*W;
            nxp = j + i*W;
            nym = (j-1) + (i-1)*W;
            
            rxm = (cMap(i,j) + cMap(i-1,j))/2.0;
            rxp = (cMap(i,j) + cMap(i+1,j))/2.0;
            rym = (cMap(i,j) + cMap(i,j-1))/2.0;

            G(n,n) = -(rxm + rxp + rym);
            G(n,nxm) = rxm;
            G(n,nxp) = rxp;
            G(n,nym) = rym;

        elseif j == 1 % bottom side = insulated

            % only three resistors:
            % n(x-1,y), n(x+1,y), n(x,y+1)

            nxm = j + (i-2)*W;
            nxp = j + i*W;
            nyp = (j+1) + (i-1)*W;
            
            rxm = (cMap(i,j) + cMap(i-1,j))/2.0;
            rxp = (cMap(i,j) + cMap(i+1,j))/2.0;
            ryp = (cMap(i,j) + cMap(i,j+1))/2.0;

            G(n,n) = -(rxm + rxp + ryp);
            G(n,nxm) = rxm;
            G(n,nxp) = rxp;
            G(n,nyp) = ryp;

        else % middle node
            
            nxm = j + (i-2)*W;
            nxp = j + i*W;
            nym = (j-1) + (i-1)*W;
            nyp = (j+1) + (i-1)*W;
            
            rxm = (cMap(i,j) + cMap(i-1,j))/2.0;
            rxp = (cMap(i,j) + cMap(i+1,j))/2.0;
            rym = (cMap(i,j) + cMap(i,j-1))/2.0;
            ryp = (cMap(i,j) + cMap(i,j+1))/2.0;
            
            % middle nodes in G, based on the sum of four neighbour cells
            G(n,n) = -(rxm + rxp + rym + ryp);
            G(n,nxm) = rxm;
            G(n,nxp) = rxp;
            G(n,nym) = rym;
            G(n,nyp) = ryp;

        end

    end
end

V = G\F;

Vmap = zeros(L,W); % initialize matrix
n = 0; % clear/reset node index n

for i = 1:L
    for j = 1:W

        n = j + (i-1)*W;
        Vmap(i,j) = V(n);

    end
end

Ex = [];
Ey = [];

for i = 1:nx
    for j = 1:ny
        
        % Calculate Ex
        
        if i == 1
            
            Ex(i,j) = Vmap(i+1,j) - Vmap(i,j);
            
        elseif i == nx
            
            Ex(i,j) = Vmap(i,j) - Vmap(i-1,j);
            
        else
            
            Ex(i,j) = (Vmap(i+1,j) - Vmap(i-1,j)) / 2.0;
            
        end
        
        % Calculate Ey
        
        if j == 1
            
            Ey(i,j) = Vmap(i,j+1) - Vmap(i,j);
            
        elseif j == ny
            
            Ey(i,j) = Vmap(i,j) - Vmap(i,j-1);
            
        else
            
            Ey(i,j) = (Vmap(i,j+1) - Vmap(i,j-1)) / 2.0;
            
        end
        
    end
end

Ex = -Ex;
Ey = -Ey;
Exy = sqrt(Ex.^2 + Ey.^2);

Jx = cMap.*Ex;
Jy = cMap.*Ey;
Jxy = sqrt(Jx.^2 + Jy.^2);

Current = mean(Jxy.*(regL*regW*10^(13)), 'all');

figure(3)
subplot(2,2,1); surf(cMap)
title('Conduction Map')
xlabel('Region Length')
ylabel('Region Width')
zlabel('Conduction (\Omega^{-1})')
view(135,45) % adjust camera angle for better view

subplot(2,2,2); surf(Vmap)
title('Electrostatic Charge')
xlabel('Region Length')
ylabel('Region Width')
zlabel('Voltage (V)')
view(135,45) % adjust camera angle for better view

subplot(2,2,3); surf(Exy)
title('Electric Field')
xlabel('Region Length')
ylabel('Region Width')
zlabel('Voltage (V/m)')
view(135,45) % adjust camera angle for better view

subplot(2,2,4); surf(Jxy)
title('Current Density')
xlabel('Region Length')
ylabel('Region Width')
zlabel('Current Density (A/m)')
view(135,45) % adjust camera angle for better view


