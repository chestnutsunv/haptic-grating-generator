clear;
close all;
clc;

%書き換えるところ
Total = 100; %mm
height = 40; %mm
lambda = 2.0; %平均周期 下限0.4
Error = 0.2; %レーザーカッター誤差用．
Periodic = 0; %Periodic:1, Random:0

%

freq = Total/lambda; %回数
floorFreq = floor(freq);

minWidthB = 0.4;
minWidthD = 0.1;
%maxWidth = lambda + (lambda - minWidth);

%Periodic用初期値
randomBump = ones(floorFreq,1);
randomDent = ones(floorFreq,1);
%(0,1)の10行1列浮動小数点一様分布　Random用
if Periodic == 0
    randomBump = rand(floorFreq,1);
    randomDent = rand(floorFreq,1);
end
%Bump, Dentの誤差込み幅
EdgeB = lambda/2 + Error;
EdgeD = lambda/2 - Error;
EdgeBumpAll = EdgeB*floorFreq;
EdgeDentAll = EdgeD*floorFreq;
%randomのスケーリング
randomBump = (EdgeBumpAll-floorFreq*minWidthB)/sum(randomBump) * randomBump;
randomDent = (EdgeDentAll-floorFreq*minWidthD)/sum(randomDent) * randomDent;

%{
レーザーカッター誤差考慮による谷幅補正
%designedBump = randomBump + laser_error - minWidth/2;
%designedBump = min(designedBump, maxWidth);
%designedDent = randomDent - laser_error;
%designedDent = max(designedDent, minWidth);
%}

%足す
rbump = minWidthB + randomBump;
rdent = minWidthD + randomDent;
%rbump = rbump + designedBump;
%rdent = rdent + designedDent;

%Average
AveBump = mean(rbump);
AveDent = mean(rdent);

randomLength = zeros(floorFreq*2,1);
randomLength(1:2:end) = rbump;
randomLength(2:2:end) = rdent;

%
states = zeros(floorFreq*2,1);
states(1:2:end) = 1;
states(2:2:end) = -1;

time = cumsum(randomLength);



X=[0:Total*2-1]/2;
Y=zeros(Total*2,1);
f = figure('Units','centimeters','Position',[0 0 10 4]);
set(f, 'PaperUnits', 'centimeters');
set(f, 'PaperSize', [10 4]);
set(f, 'PaperPositionMode', 'manual');
set(f, 'PaperPosition', [0 0 10 4]);

hold on;
for i=1:length(time)-1
    if states(i)==1
        fill([time(i),time(i+1),time(i+1), time(i)],[40,40,0,0],'k','EdgeColor','none');
    else
        fill([time(i),time(i+1),time(i+1),time(i)],[40,40,0,0],'w','EdgeColor','none');
    end
end

rectangle('Position', [0, 0, Total+0.5, height], 'EdgeColor','r', 'LineWidth', 1);

xlim([0 Total+0.5]);
ylim([0 height+0.5]);
axis equal;
axis off;
xticks([]);
yticks([]);

ax = gca;
set(ax, 'Units', 'centimeters');
set(ax, 'Position', [0 0 10 4]);

if Periodic == 0
    string = "Random";
else
    string = "Periodic";
end
filename = sprintf('%s%.2f-%.2f.pdf', string, EdgeB, EdgeD);
exportgraphics(gcf, filename, 'ContentType', 'vector', 'BackgroundColor','white', 'Resolution', 600);

hold off;
