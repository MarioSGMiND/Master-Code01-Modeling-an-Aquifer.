% clear workspace.
clear all
close all
clc

% Inicialización de Parámetros.
% Dominio.
X0 = 0.0; Xf = 1.0; dx = 0.2;
Y0 = 0.0; Yf = 2.0; dy = 0.2;

% Generar la Partición.
x = [X0:dx:Xf];
y = [Y0:dy:Yf];

% Definir Matrices.
n = length(x)+2;
m = length(y);
    % Funcion de MATLAB para crear Matrices de 1's-> ones(n,m).
    % Funcion de MATLAB para crear Matrices de 0's-> zeros(n,m).
h = zeros(m,n);
qx = zeros(m,n); % Generación de matrices Eq. 17
qy = zeros(m,n); % Generación de matrices Eq. 17
materror = ones(m-2,n-2);

% Parámetros hidraulicos.
c = 0.02;
sx = 0.372176150943543; % Conductividad hidráulica en el Eje X (Valor del Paper)
sy = 0.372175590827833; % Conductividad hidráulica en el Eje Y (Valor del Paper)

% Parametros de Iteración.
tol = 0.5e-6; % Tolerancia de error. (es)
nmax = 1e6; % Número máximo de iteraciones. (Fin)
numit = 0; % Contador de iteraciones. (Inicio)
error = 1.0; % Error máximo permitido.
e = zeros(1,nmax); % Vector para almacenar el error, hasta llegar a lo máximo permitido.

% Condición de frontera superior.
    % Definición de una función anónima (sirve sólo en el código presente).
    % Se debe definir en una sola línea o línea continua.
hSup = @(x) c*x+Yf;
% Condición de frontera inferior.
hInf = @(x) -c*x+Yf;

% Satisfacer las condiciones de frontera superior e inferior.
for j = 2:n-1
   h(m,j) = hSup(x(j-1)); % Frontera Superior.
   h(1,j) = hInf(x(j-1)); % Frontera Inferior.
end

% Satisfacer las condiciones de frontera del eje X y Y (rango de X0 a Xf).
for i = 2:m-1
    h(i,1) = h(i,3); % En X0
    h(i,n) = h(i,n-2);% En Xf
end

% Parámetros para graficar.
%hgraf = zeros(m-1,n-2);
% Eliminar columnas de 0's de izquierda, derecha e inferior.
    % Tic/Toc nos muestra en terminal el tiempo que toma nuestro codigo en
    % correr.
%tic % Inicio
%for i = 1:m-1
    %for j = 1:n-2
        %hgraf(i,j) = h(i+1,j+1);
    %end
%end
%toc % Fin

%Parámetros para graficar.
hgraf=h;
hgraf(:,n) = []; % Eliminar columna de 0's derecha.
hgraf(:,1) = []; % Eliminar columna de 0's izquierda.

% Generar gráfica 
figure(1);
surface(x,y,hgraf); %instruccion que grafica
shading interp;
xlabel('x');
ylabel('y');
zlabel('h(x,y)');
title('Nivel freático de pendiente líneal');
view(3);

tic
while true
    numit = numit+1;
% Iterar una vez a lo largo de la matriz.
    for i = 2:m-1
        for j = 2:n-1
            oldval = h(i,j); % Declaramos la variable "oldval" en forma matrial.
            h(i,j) = (h(i+1,j)+h(i-1,j)+h(i,j+1)+h(i,j-1))/4;
            materror(i-1,j-1) = abs((h(i,j)-oldval)/h(i,j)); % Damos la forma a la matriz en valor absoluto "abs".
        end
    end
         % Satisfacer las condiciones de frontera superior e inferior.
        for j = 2:n-1
           h(m,j) = hSup(x(j-1)); % Frontera Superior.
           h(1,j) = hInf(x(j-1)); % Frontera Inferior.
        end
        % Satisfacer las condiciones de frontera del eje X y Y (rango de X0 a Xf).
        for i = 2:m-1
            h(i,1) = h(i,3); % En X0
            h(i,n) = h(i,n-2);% En Xf
        end
        % Selecionamos el error máximo.
        % Usamos la función max(A) si A es una matriz devuelve un vector
        % con los elementos máximos de c/columna, si A es un vector 
        % devuelve el máximo del vector
        error = max(max(materror));
        e(numit) = error;
        % Condición de salida del ciclo while
        % break ("frena" la evaluación) end (termina el ciclo while).
        if error < tol || numit >= nmax, break,end
end
toc

%Parámetros para graficar.
hgraf=h;
hgraf(:,n) = []; % Eliminar columna de 0's derecha.
hgraf(:,1) = []; % Eliminar columna de 0's izquierda.

% Generar gráfica 
figure(2);
surface(x,y,hgraf); %instruccion que grafica
shading interp;
xlabel('x');
ylabel('y');
zlabel('h(x,y)');
title('Nivel freático de pendiente líneal');
view(3);

% Cálculo de las componentes del vector de flujo.
for i = 2:m-1
    for j = 2:n-1
        qx(i,j) = -sx*(h(i,j+1)-h(i,j-1))/(2*dx);
        qy(i,j) = -sy*(h(i+1,j)-h(i-1,j))/(2*dy);
    end
end

% Componente qx en la frontera superior.
for j = 2:n-1
    qx(m,j) = -c*sx;
    qy(m,j) = 0.0;
end

% Componente qx en la frontera inferior.
for j = 2:n-1
    qx(m,j) = c*sx;
    qy(m,j) = 0.0;
end

h

% Generacion de matrices para graficar valores del vector de flujo.
% Se genera la matriz para conservar los valores de qx y qy.
qxgraf=qx; % Almacenamiento de valores qx en una matriz nueva.
% Remover filas y columnas ficticias en la nueva matriz qxgraf.
qxgraf(:,1) = []; 
qxgraf(:,n-1) = []; 
qxgraf(1,:) = [];

qygraf=qy; % Almacenamiento de valores qy en una matriz nueva.
% Remover filas y columnas ficticias en la nueva matriz qygraf.
qygraf(:,1) = [];
qygraf(:,n-1) = [];
qygraf(1,:) = [];

% Generación de la malla.
[X,Y] = meshgrid(x,y);
figure(3);
% Funcion para graficar el flujo.
quiver(qxgraf,qygraf);
title("Flujo de Agua del Caudal");

% Funcion find busca todos los valores y recorta a numit
indices = find(e==0); % find genera un vector con los valores donde hay un 0
e(indices) = []; % coloca en un arraqy vacio los ceros

tic
% Generación de gráfica del error.
figure(4);
plot(e,'*');
title("% Error por Iteración");
toc