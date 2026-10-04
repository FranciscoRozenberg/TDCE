% =========================================================================
% Script completo para leer Bode y estimar Transferencia (Orden Superior)
% =========================================================================

clear; clc; close all;

% --- 1. Cargar y leer el archivo .txt ---
filename = 'Regulador_MOS_SIN_LC_SIN_COMPENSAR.txt'; % Asegúrate de que coincida con tu archivo

fid = fopen(filename, 'r');
if fid == -1
    error('No se pudo abrir el archivo. Verifica el nombre y la ruta.');
end

fgetl(fid); % Saltar cabecera
data_cell = textscan(fid, '%f (%fdB,%f°)');
fclose(fid);

freq_Hz = data_cell{1};       
mag_dB  = data_cell{2};       
phase   = data_cell{3};       

% --- 2. Preparar los datos ---
w = freq_Hz * 2 * pi;             
mag = 10.^(mag_dB / 20);          
phase_rad = phase * (pi / 180);   

% (Opcional) Si quieres descartar frecuencias extremas con ruido al final:
% idx = w <= 1e8; % Nos quedamos hasta 10^8 rad/s
% w = w(idx); mag = mag(idx); phase_rad = phase_rad(idx);

H = mag .* exp(1j * phase_rad);
data_frd = idfrd(H, w, 0);

% --- 3. Estimar con 4 polos y 2 ceros para evitar el rebote de fase ---
np = 4; 
nz = 2; 

sys = tfest(data_frd, np, nz);

% --- 4. Mostrar resultados y graficar ---
disp('--- Función de Transferencia Estimada (Optimizada) ---');
disp(sys);

figure('Name', 'Identificacion de Sistemas - Bode Final', 'Color', 'white');
bode(data_frd, sys);
legend('Datos del Archivo .txt', sprintf('Modelo Estimado (np=%d, nz=%d)', np, nz), 'Location', 'southwest');
grid on;