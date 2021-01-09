syms X Y Z Xx Yy Zz B mu R angle1 angle2 x I t;

%constants
mu = 4*pi*10^(-7); %vacuum permeability constant
R = 0.069; %radius of the solenoid in m %CHANGE
I = 0.75; %current through solenoid in A
N = 320; %number of windings %CHANGE
H = 0.0191; %width of coil in m %CHANGE
numpoints = 20*N;
simrange = 0.3; %how far the sim goes
simdensity = simrange/10; %how many points per meter
quiverdensity = 8; %higher means less points lmao
quiverscale = 0.05;

uniti = [1, 0, 0];
unitj = [0, 1, 0];
unitk = [0, 0, 1];

%initial positions
s01 = [0, 0, 0];
s02 = [0, 0.15, 0];

angle1 = [0, 0, 0] *pi/180; %angle of first solenoid (rad)
angle2 = [7, 69, 21] *pi/180; %angle of second solenoid (rad) %CHANGE

%create solenoid1
%t1 = 0:pi/20:N*pi;
t1 = linspace(0, N*pi, numpoints);
st1 = R*sin(t1);
ct1 = R*cos(t1);
t1 = H*t1/(N*pi);
solenoid1coords = [t1; st1; ct1];
%create solenoid2
%t2 = 0:pi/20:N*pi;
t2 = linspace(0, N*pi, numpoints);
st2 = R*sin(t2);
ct2 = R*cos(t2);
t2 = H*t2/(N*pi);
solenoid2coords = [t2; st2; ct2];

%rotation matrix of solenoid1 
RM_x1 = [1, 0, 0;                               0, cos(angle1(1)), -sin(angle1(1));     0, sin(angle1(1)), cos(angle1(1))];
RM_y1 = [cos(angle1(2)), 0, sin(angle1(2));     0, 1, 0;                                -sin(angle1(2)), 0, cos(angle1(2))];
RM_z1 = [cos(angle1(3)), -sin(angle1(3)), 0;    sin(angle1(3)), cos(angle1(3)), 0;      0, 0, 1];
%rotation matrix of solenoid2
RM_x2 = [1, 0, 0;                               0, cos(angle2(1)), -sin(angle2(1));     0, sin(angle2(1)), cos(angle2(1))];
RM_y2 = [cos(angle2(2)), 0, sin(angle2(2));     0, 1, 0;                                -sin(angle2(2)), 0, cos(angle2(2))];
RM_z2 = [cos(angle2(3)), -sin(angle2(3)), 0;    sin(angle2(3)), cos(angle2(3)), 0;      0, 0, 1];

%rotate the solenoids and shift them on god
totalrotation1 = RM_x1*RM_y1*RM_z1;
totalrotation2 = RM_x2*RM_y2*RM_z2;
solenoid1coords = totalrotation1*solenoid1coords + transpose(s01);
solenoid2coords = totalrotation2*solenoid2coords + transpose(s02);

%UNUSED
%simx = linspace(-simrange, simrange, simdensity*simrange*2);
%simy = linspace(-simrange, simrange, simdensity*simrange*2);
%simz = linspace(-simrange, simrange, simdensity*simrange*2);
%Bx = zeros(1, length(simx));
%By = zeros(1, length(simy));
%Bz = zeros(1, length(simz));


simcoords = zeros(simrange/simdensity, simrange/simdensity, simrange/simdensity, 3);
simB = zeros(simrange/simdensity, simrange/simdensity, simrange/simdensity,3);

coordinates = zeros(3, (simrange/simdensity)^3);
simBx = zeros((simrange/simdensity)^3);
simBy = zeros((simrange/simdensity)^3);
simBz = zeros((simrange/simdensity)^3);

simx = zeros((simrange/simdensity)^3);
simy = zeros((simrange/simdensity)^3);
simz = zeros((simrange/simdensity)^3);

n=1;
for i = 1:simrange/simdensity
    for j = 1:simrange/simdensity
        for k = 1:simrange/simdensity
            simcoords(i, j, k,:) = [i*simdensity - simrange/2, j*simdensity - simrange/2 k*simdensity - simrange/2];
            coordinates(:, n) = [i*simdensity-simrange/2, j*simdensity-simrange/2, k*simdensity-simrange/2];
            
            simx(n) = i;
            simy(n) = j;
            simz(n) = k;
            
            simBx(n) = i;
            simBy(n) = j;
            simBz(n) = k;
            n = n + 1;
            DELETE THIS AFTERWARDS
            simBx(i, j, k, :) = [i, j, k];
        end
    end
end

simx = linspace(simdensity-simrange/2, simrange/2, simrange/simdensity);
simy = linspace(simdensity-simrange/2, simrange/2, simrange/simdensity);
simz = linspace(simdensity-simrange/2, simrange/2, simrange/simdensity);

simx = coordinates(1,:);
simy = coordinates(2,:);
simz = coordinates(3,:);


% h = waitbar(0,'waiting')
% for i = 1:simrange/simdensity
%     for j = 1:simrange/simdensity
%         for k = 1:simrange/simdensity
%             coords = simcoords(i, j, k); %point P
%             Bx = 0;
%             By = 0; 
%             Bz = 0;
%             for t = 1:numpoints
%                 coords = simcoords(i, j, k,:); %point P
%                 
%                 %solenoid1
%                 dBx = (mu*I/4*pi)/( (coords(1)-solenoid1coords(2,t))^2 + coords(2)^2 + (coords(3) + solenoid1coords(3,t))^2 )^1.5 * dot(cross( [solenoid1coords(3,t), 0, solenoid1coords(2,t)], [coords(1)-solenoid1coords(2,t), coords(2), coords(3)+solenoid1coords(2,t)]), uniti) * pi/simdensity;
%                 dBy = (mu*I/4*pi)/( (coords(1)-solenoid1coords(2,t))^2 + coords(2)^2 + (coords(3) + solenoid1coords(3))^2 )^1.5 * dot(cross( [solenoid1coords(3), 0, solenoid1coords(2)], [coords(1)-solenoid1coords(2), coords(2), coords(3)+solenoid1coords(2)]), unitj) * pi/simdensity;
%                 dBz = (mu*I/4*pi)/( (coords(1)-solenoid1coords(2))^2 + coords(2)^2 + (coords(3) + solenoid1coords(3))^2 )^1.5 * dot(cross( [solenoid1coords(3), 0, solenoid1coords(2)], [coords(1)-solenoid1coords(2), coords(2), coords(3)+solenoid1coords(2)]), unitk) * pi/simdensity;
%                 %solenoid2
%                 dBx = dBx + (mu*I/4*pi)/( (coords(1)-solenoid2coords(2))^2 + coords(2)^2 + (coords(3) + solenoid2coords(3))^2 )^1.5 * dot(cross( [solenoid2coords(3), 0, solenoid2coords(2)], [coords(1)-solenoid2coords(2), coords(2), coords(3)+solenoid2coords(2)]), uniti) * pi/simdensity;
%                 dBy = dBy + (mu*I/4*pi)/( (coords(1)-solenoid2coords(2))^2 + coords(2)^2 + (coords(3) + solenoid2coords(3))^2 )^1.5 * dot(cross( [solenoid2coords(3), 0, solenoid2coords(2)], [coords(1)-solenoid2coords(2), coords(2), coords(3)+solenoid2coords(2)]), unitj) * pi/simdensity;
%                 dBz = dBz + (mu*I/4*pi)/( (coords(1)-solenoid2coords(2))^2 + coords(2)^2 + (coords(3) + solenoid2coords(3))^2 )^1.5 * dot(cross( [solenoid2coords(3), 0, solenoid2coords(2)], [coords(1)-solenoid2coords(2), coords(2), coords(3)+solenoid2coords(2)]), unitk) * pi/simdensity;
%                 
%                 simBx(n) = simBx(n) + dBx;
%                 simBy(n) = simBy(n) + dBy;
%                 simBz(n) = simBz(n) + dBz;
%             end
%             %simB(i,j,k,:) = [Bx, By, Bz];
%         end
%         waitbar(i/simrange*simdensity,h);
%     end
% end
% delete(h); %delete progress bar

hold on
%plot solenoids
plot3(solenoid1coords(1,:), solenoid1coords(2,:), solenoid1coords(3,:));
plot3(solenoid2coords(1,:), solenoid2coords(2,:), solenoid2coords(3,:));

%plot B field
simx = simx(1:quiverdensity:end);
simy = simy(1:quiverdensity:end);
simz = simz(1:quiverdensity:end);
simBx = simBx(1:quiverdensity:end);
simBy = simBy(1:quiverdensity:end);
simBz = simBz(1:quiverdensity:end);

allB = [simBx; simBy; simBz];
unitB = ones(size(allB));
for i = 1:length(allB(1, :)) %copied off nick
    unitB(:, i) = allB(:, i)/norm(allB(:, i))/quiverscale;
end

quiver3(simx, simy, simz, unitB(1,:), unitB(2,:), unitB(3,:));
view(-35,45)
