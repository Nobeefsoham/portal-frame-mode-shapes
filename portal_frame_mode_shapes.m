clc; clear all; close all;
graphics_toolkit('qt');

disp('--> Calculating Portal Frame Mode Shapes...');

N_segments = 3;

% Geometry (25mm height in bending plane, 2mm thickness out-of-plane)
h = 0.025; % Height [m]
t = 0.002; % Thickness [m]

A_plate = h * t;
I_plate = (t * h^3) / 12;

% Segments: 1 (Steel Leg 1), 2 (Aluminum Top Span), 3 (Steel Leg 2)
L   = [0.150, 0.125, 0.150];
E   = [2e11, 7.1e10, 2e11];
I   = [I_plate, I_plate, I_plate];
rho = [7850, 2770, 7850];
A   = [A_plate, A_plate, A_plate];

%% 90-degree Corner Matrix
R = [ 0,  1,  0,  0,  0,  0;
     -1,  0,  0,  0,  0,  0;
      0,  0,  1,  0,  0,  0;
      0,  0,  0,  0,  1,  0;
      0,  0,  0, -1,  0,  0;
      0,  0,  0,  0,  0,  1];

% ANSYS Target Frequencies
f_ansys = [70.60, 296.64, 381.70]; % Hz
w_ansys = 2 * pi * f_ansys;        % rad/s

%% Display Frequencies in Command Window
disp('===================================================');
disp('               NATURAL FREQUENCIES                 ');
disp('===================================================');
for i = 1:length(f_ansys)
    fprintf('Mode %d:  %8.2f rad/s   |   %7.2f Hz\n', i, w_ansys(i), f_ansys(i));
end
disp('===================================================');

%% Solve Mode Shapes & Plot
figure(1); clf; hold on;
colors = {'r', 'g', 'b'};

for i = 1:length(w_ansys)
    w = w_ansys(i);

    % Populate B matrices with correct sign: dM/dx = +V -> B(6,5) = 1
    B1 = zeros(6,6); B1(1,4)=1/(E(1)*A(1)); B1(2,3)=1; B1(3,6)=1/(E(1)*I(1)); B1(4,1)=-rho(1)*A(1)*w^2; B1(5,2)=rho(1)*A(1)*w^2; B1(6,5)=1;
    B2 = zeros(6,6); B2(1,4)=1/(E(2)*A(2)); B2(2,3)=1; B2(3,6)=1/(E(2)*I(2)); B2(4,1)=-rho(2)*A(2)*w^2; B2(5,2)=rho(2)*A(2)*w^2; B2(6,5)=1;
    B3 = zeros(6,6); B3(1,4)=1/(E(3)*A(3)); B3(2,3)=1; B3(3,6)=1/(E(3)*I(3)); B3(4,1)=-rho(3)*A(3)*w^2; B3(5,2)=rho(3)*A(3)*w^2; B3(6,5)=1;

    FTM1 = expm(B1 * L(1));
    FTM2 = expm(B2 * L(2));
    FTM3 = expm(B3 * L(3));

    GTM = FTM3 * R * FTM2 * R * FTM1;
    U_sub = GTM(1:3, 4:6);

    [~, ~, V_svd] = svd(U_sub);
    f0 = V_svd(:, end);
    Z = [0; 0; 0; f0(1); f0(2); f0(3)];

    % Leg 1 (Vertical, ascending)
    x1 = linspace(0, L(1), 40);
    dX1 = zeros(size(x1)); dY1 = zeros(size(x1));
    for k = 1:length(x1)
        Z_x = expm(B1 * x1(k)) * Z;
        dX1(k) = -Z_x(2);
        dY1(k) =  Z_x(1);
    end

    Z = R * (FTM1 * Z);

    % Top Span (Horizontal)
    x2 = linspace(0, L(2), 40);
    dX2 = zeros(size(x2)); dY2 = zeros(size(x2));
    for k = 1:length(x2)
        Z_x = expm(B2 * x2(k)) * Z;
        dX2(k) = Z_x(1);
        dY2(k) = Z_x(2);
    end

    Z = R * (FTM2 * Z);

    % Leg 2 (Vertical, descending)
    x3 = linspace(0, L(3), 40);
    dX3 = zeros(size(x3)); dY3 = zeros(size(x3));
    for k = 1:length(x3)
        Z_x = expm(B3 * x3(k)) * Z;
        dX3(k) =  Z_x(2);
        dY3(k) = -Z_x(1);
    end

    % Scale factor for visibility
    max_deflection = max(abs([dX1, dX2, dX3, dY1, dY2, dY3]));
    scale = 0.02 / max_deflection;

    % Plot deformed portal frame
    plot(0 + scale*dX1, x1 + scale*dY1, colors{i}, 'linewidth', 2, 'DisplayName', sprintf('Mode %d (%.2f Hz / %.1f rad/s)', i, f_ansys(i), w_ansys(i)));
    plot(x2 + scale*dX2, L(1) + scale*dY2, colors{i}, 'linewidth', 2, 'HandleVisibility', 'off');
    plot(L(2) + scale*dX3, (L(1) - x3) + scale*dY3, colors{i}, 'linewidth', 2, 'HandleVisibility', 'off');
end

% Plot reference undeformed structure
plot([0, 0, L(2), L(2)], [0, L(1), L(1), 0], 'k--', 'linewidth', 1.5, 'DisplayName', 'Undeformed');

title('2D Mode Shapes for Fixed-Fixed Portal Frame');
xlabel('X Position (m)');
ylabel('Y Position (m)');
axis equal; grid on; box on; legend('location', 'northeast');

drawnow;
