function plot_phase_tensor_ellipse_pseudo(d)
%
% Function which plots phase tensors ellipes in pseudo-section format and
% colors the ellipses with beta skew angle
%
% Usage: plot_phase_tensor_ellipse_pseudo(d)
%
% "d" is an MT data structure
%
%%
close all
u = user_defaults;

%Pull a profile to plot the pseudo-section. "sidx" is stations indices
%included on profile and "rot_ang" is the direction of the normal to the
%profile direction
[sidx,midpoint,azimuth] = get_pseudo_section_indices(d);

rad = 180./pi;      

% Process cooordinates
lon_mean = midpoint(1);  lat_mean = midpoint(2); % km
x = cos(lat_mean/rad)*111*(d.loc(sidx,2)-lon_mean);y = 111*(d.loc(sidx,1)-lat_mean); % km
N = length(sidx); %Number of stations included in profile

c = cosd(azimuth);      s = sind(azimuth);     R = [ c, -s ; s, c];

%Rotate station coordinates to get distance along profile
x_rot = zeros(N,1); y_rot = zeros(size(x_rot));
for is=1:N
    loc = [x(is),y(is)];    loc = R*loc';
    x_rot(is) = loc(1);     y_rot(is)=loc(2);
end

% Put stations in order of monotonically increasing x_rot
[x_sort,index] = sort(x_rot,'ascend');
index = sidx(index);

%Initialize arrays
beta = nan(d.nf,d.ns); alpha = nan(size(beta)); e = nan(size(beta));
strike = nan(size(beta)); phimin = nan(size(beta)); phimax = nan(size(beta));
max_pt = nan(size(beta));

for is = 1:u.sskip:d.ns  % Loop over stations

    [p] = calc_phase_tensor(d.Z(:,:,is)); %Calculate phase tensor parameters

    %Put all the phase tensor parameters into matrices of size nf x ns
    beta(:,is) = p.beta;
    alpha(:,is) = p.alpha;
    e(:,is) = p.e;
    strike(:,is) = p.strike;
    phimin(:,is) = p.phimin;
    phimax(:,is) = p.phimax;
    max_pt(:,is) = p.max_pt;
    ptx(:,:,is) = p.x;
    pty(:,:,is) = p.y;
    

end
%%
%Plot pseudo-section
set_figure_size(1);
betacutoff = 10^6;
colormap(flipud(u.cmap));
%Set vertical scaling for periods and phase tensor ellipses
aspect_ratio = (max(x_sort)-min(x_sort))/(max(log10(d.T))-min(log10(d.T)));
if aspect_ratio == 0 % 1 station
    aspect_ratio = 1;
end

for ifreq = 1:u.nskip:d.nf
    for is = 1:N %Loop of stations included on profile
        
        if abs(beta(ifreq,index(is)))<=betacutoff
            scale = u.pt_pseudo_scale*((max(x_sort)-min(x_sort))/length(x_sort))/max_pt(ifreq,index(is))*(((max(log10(d.T)))-min(log10(d.T)))/(d.nf));
            if scale == 0 % 1 station
                scale = u.pt_pseudo_scale/max_pt(ifreq,index(is))*(((max(log10(d.f)))-min(log10(d.f)))/(d.nf));
            end
            xp = x_sort(is)+scale*pty(:,ifreq,index(is)); %X location on profile 
            %xp = 2*is+scale*pty(:,ifreq,index(is)); %Option to plot site-by-site rather as distance

            % Note the minus sign below - this is to negate the flip from axis ij later on
            yp = log10(d.T(ifreq))-scale*ptx(:,ifreq,index(is))./aspect_ratio;  %Y location in period
            if strcmp(u.phase_tensor_ellipse_fill,'phimin')
                fill(xp,yp,abs(phimin(ifreq,index(is)))); hold on %Plot filled ellipses with phi min
            elseif strcmp(u.phase_tensor_ellipse_fill,'beta')
                fill(xp,yp,abs(beta(ifreq,index(is)))); hold on %Plot filled ellipses with beta skew angle
            else
                disp('Unrecognized input for u.phase_tensor_ellipse_fill. Ellipses are filled with beta skew angle values. Check your user_defaults')
                fill(xp,yp,abs(beta(ifreq,index(is)))); hold on %Plot filled ellipses with beta skew angle
            end
        
        end
    end
end

daspect(gca,[aspect_ratio 1 1]);

%Plot station locations on profile
dx = 0.05*(x_sort(end) - x_sort(1));
axis ij
plot(x_sort,log10(d.T(1))-0.25,'kv','MarkerFaceColor','k')


ylabel('Log(Period (s))')
xlabel('Distance Along Profile (km)');
if dx ==0
    axis([x_sort(1)-1,x_sort(N)+1, min(log10(d.T))-0.5 ,max(log10(d.T))])
else
    axis([x_sort(1)-dx,x_sort(N)+dx, min(log10(d.T))-0.5 ,max(log10(d.T))])
end

if u.station_names
    text(x_sort,(x_sort.*0 )+ min(log10(d.T))-0.5,d.site(index),'rotation',u.station_names_angle,'interpreter','none');
else
    title('Phase Tensor Pseudo Section')
end

set(gca,'Layer','top');

if strcmp(u.phase_tensor_ellipse_fill,'phimin')
    caxis(u.phase_tensor_phimin_colim);
    hcb = colorbar;
    hcb.Label.String = '\Phi_{min} (degrees)';
else
    caxis(u.phase_tensor_beta_colim);
    hcb = colorbar;
    hcb.Label.String = 'Beta Skew Angle (degrees)';
end

set(gca,'fontsize',20)

print_figure(['phase_tensor_',d.niter],['pseudo_ellipse_',num2str(lat_mean),'_lat_',num2str(lon_mean),'_lon']); %Save figure

