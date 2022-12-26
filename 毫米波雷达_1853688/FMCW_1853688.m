%% 雷达波型参数

fc = 77e9;   %工作频率
c = 3e8;   %光速
lambda = c/fc;   %波长

range_max = 200;   %最大可视距离为200m
tm = 5.5*range2time(range_max,c);   %Tc取为tao的5.5倍

range_res = 1;   %距离分辨率为1m
bw = rangeres2bw(range_res,c);   %计算带宽
sweep_slope = bw/tm;   %调频连续波f-t图像的斜率

%%

fr_max = range2beat(range_max,sweep_slope,c);   %最大范围对应的频率
v_max = 230*1000/3600;   
fd_max = speed2dop(2*v_max,lambda);   %最大多普勒移位频率
fb_max = fr_max+fd_max;   %最大节拍频率

fs = max(2*fb_max,bw);   

%%

%工作频率（GHz）77

%最大目标距离（米）200

%距离分辨率（m）1

%最大目标速度（km/h）230

%扫描时间（微秒）7.33

%扫描带宽（MHz）150

%最大拍频（MHz）27.30

%采样率（MHz）150


%% 检查波形

waveform = phased.FMCWWaveform('SweepTime',tm,'SweepBandwidth',bw,...
'SampleRate',fs);   %设置波形
sig = waveform();
figure(1);
subplot(211); plot(0:1/fs:tm-1/fs,real(sig));   %画出调频连续波的A-t图
xlabel('Time (s)'); ylabel('Amplitude (v)');
title('FMCW signal'); axis tight;
subplot(212); spectrogram(sig,32,16,32,fs,'yaxis');   %画出调频连续波的f-t图
title('FMCW signal spectrogram');

%% 目标模型建立

car_dist = 43;   %车距
car_speed = 96*1000/3600;   %车速
car_rcs = db2pow(min(10*log10(car_dist)+5,20));   %雷达散射截面

cartarget = phased.RadarTarget('MeanRCS',car_rcs,'PropagationSpeed',c,...
    'OperatingFrequency',fc);  
carmotion = phased.Platform('InitialPosition',[car_dist;0;0.5],...
    'Velocity',[car_speed;0;0]);    %车辆建模

channel = phased.FreeSpace('PropagationSpeed',c,...
    'OperatingFrequency',fc,'SampleRate',fs,'TwoWayPropagation',true);

%% 雷达系统设置

ant_aperture = 6.06e-4;                         % 雷达光圈（平方米）
ant_gain = aperture2gain(ant_aperture,lambda);  % 增益

tx_ppower = db2pow(5)*1e-3;                     % 发射功率
tx_gain = 9+ant_gain;                           % 发射增益

rx_gain = 15+ant_gain;                          % 接收功率
rx_nf = 4.5;                                    

transmitter = phased.Transmitter('PeakPower',tx_ppower,'Gain',tx_gain);   %发射模型
receiver = phased.ReceiverPreamp('Gain',rx_gain,'NoiseFigure',rx_nf,...
    'SampleRate',fs);   %接收模型

radar_speed = 100*1000/3600;   %雷达速度（自车速）
radarmotion = phased.Platform('InitialPosition',[0;0;0.5],...
    'Velocity',[radar_speed;0;0]);   %雷达姿态

%% 雷达信号模拟

specanalyzer = dsp.SpectrumAnalyzer('SampleRate',fs,...
    'PlotAsTwoSidedSpectrum',true,...
    'Title','Spectrum for received and dechirped signal',...
    'ShowLegend',true);
    

%%

rng(2012);
Nsweep = 64;
xr = complex(zeros(waveform.SampleRate*waveform.SweepTime,Nsweep));

for m = 1:Nsweep
    % 更新雷达和目标的位置
    [radar_pos,radar_vel] = radarmotion(waveform.SweepTime);
    [tgt_pos,tgt_vel] = carmotion(waveform.SweepTime);

    % 发射调频连续波
    sig = waveform();
    txsig = transmitter(sig);
    
    % 传播信号并反射到目标上
    txsig = channel(txsig,radar_pos,tgt_pos,radar_vel,tgt_vel);
    txsig = cartarget(txsig);
    
    % 对接收到的雷达回波进行消隐
    txsig = receiver(txsig);    
    dechirpsig = dechirp(txsig,sig);
    
    % 生成光谱
    specanalyzer([txsig dechirpsig]);
    
    xr(:,m) = dechirpsig;
end

%% 范围和多普勒估计

rngdopresp = phased.RangeDopplerResponse('PropagationSpeed',c,...
    'DopplerOutput','Speed','OperatingFrequency',fc,'SampleRate',fs,...
    'RangeMethod','FFT','SweepSlope',sweep_slope,...
    'RangeFFTLengthSource','Property','RangeFFTLength',2048,...
    'DopplerFFTLengthSource','Property','DopplerFFTLength',256);

clf;
figure(2);
plotResponse(rngdopresp,xr);                     % 距离多普勒
axis([-v_max v_max 0 range_max])
clim = caxis;

Dn = fix(fs/(2*fb_max));
for m = size(xr,2):-1:1
    xr_d(:,m) = decimate(xr(:,m),Dn,'FIR');
end
fs_d = fs/Dn;

% 使用连贯的集成扫描来估计节拍频率，然后转换为范围

fb_rng = rootmusic(pulsint(xr_d,'coherent'),1,fs_d);
rng_est = beat2range(fb_rng,sweep_slope,c)

% 多普勒移位估计在目标所在范围内进行扫描

peak_loc = val2ind(rng_est,c/(fs_d*2));
fd = -rootmusic(xr_d(peak_loc,:),1,1/tm);
v_est = dop2speed(fd,lambda)/2

%% 范围多普勒耦合效果

deltaR = rdcoupling(fd,sweep_slope,c)   %计算多普勒耦合的范围

%汽车雷达通常使用更长的扫描时间。更长的扫描时间使多普勒耦合范围更加突出。
waveform_tr = clone(waveform);
release(waveform_tr);
tm = 2e-3;   %以 2 ms 作为扫描时间。
waveform_tr.SweepTime = tm;
sweep_slope = bw/tm;

deltaR = rdcoupling(fd,sweep_slope,c)   %重新计算多普勒耦合的范围

%雷达系统使用传统的多普勒处理程序可以检测到速度分辨率是
v_unambiguous = dop2speed(1/(2*tm),lambda)/2  
%速度分辨率只有0.48米/s，这意味着相对速度，1.11米/s，不能明确检测。

%% 设置三角扫描波形

waveform_tr.SweepDirection = 'Triangle';

Nsweep = 16;   %扫描16次
xr = helperFMCWSimulate(Nsweep,waveform_tr,radarmotion,carmotion,...
    transmitter,channel,cartarget,receiver);

% 向上扫荡和向下扫除分别处理，以获得与上下扫荡对应的节拍频率。
fbu_rng = rootmusic(pulsint(xr(:,1:2:end),'coherent'),1,fs);
fbd_rng = rootmusic(pulsint(xr(:,2:2:end),'coherent'),1,fs);

%获得正确的范围估计值
rng_est = beat2range([fbu_rng fbd_rng],sweep_slope,c)

%多普勒移位和速度也可以以类似的方式恢复
fd = -(fbu_rng+fbd_rng)/2;
v_est = dop2speed(fd,lambda)/2

%% 使用两个射线通道模型在雷达和目标车辆之间传播信号。

txchannel = phased.TwoRayChannel('PropagationSpeed',c,...
    'OperatingFrequency',fc,'SampleRate',fs);
rxchannel = phased.TwoRayChannel('PropagationSpeed',c,...
    'OperatingFrequency',fc,'SampleRate',fs);
Nsweep = 64;
xr = helperFMCWTwoRaySimulate(Nsweep,waveform,radarmotion,carmotion,...
    transmitter,txchannel,rxchannel,cartarget,receiver);
figure(3);
plotResponse(rngdopresp,xr);                     % 距离多普勒
axis([-v_max v_max 0 range_max]);
caxis(clim);
