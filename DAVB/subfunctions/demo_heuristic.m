% demo for the Kilner heuristic

% excitatory maximum post-synaptic depolarization
P.me = 1e-0*8;
% inhibitory maximum post-synaptic depolarization
P.mi = 1e-0*32;
% excitatory post-synaptic time constant
P.Ke = 1e-3/4;
% inhibitory post-synaptic time constant
P.Ki = 1e-3/28;
% amplitude of intrinsic connectivity kernels
P.a = 1e3.* [ 0 0 2
              0 0 8
              2 1 0 ];
% intrinsic connectivity decay constant
P.c = 1e3*0.32.*ones(3,3); 
% conduction velocity
P.v = 3.*ones(3,3); 
% radius of cortical source
P.l = 50.*1e-3;
% parameters of the Gaussian observation filter
P.phi = [1;0.01.*P.l];
% parameters of the Gaussian observation filter
P.sig = struct('r',0.54,'eta',30*1e-0,'g',0.135);
% frequency grid
gridw = .1:1e-1:120;

gridx = -50:1e0:50;
nt = numel(gridx);
gy = zeros(numel(gridw),nt);

for t=1:nt
    [g] = dsdv(gridx(t),P);
    [gy(:,t)] = spectralPower2(P,gridw,g)';
    t
end

ngy = gy;
mf = zeros(1,nt);
for t=1:nt
    ngy(:,t) = ngy(:,t)./sum(ngy(:,t));
    mf(t) = sum(sqrt(ngy(:,t)).*gridw');
end

hf = figure;
ha = subplot(2,1,2,'parent',hf);
plot(ha,gridx,mf);
ha = subplot(2,1,1,'parent',hf);
mesh(ha,log(gy));
axis(ha,'tight')

