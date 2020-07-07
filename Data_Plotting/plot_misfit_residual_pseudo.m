function plot_misfit_residual_pseudo(dobs,dpred)
%
% Function which plots apparent resistivity and phase pseudosections for xy
% and yx mdoes
%
% Usage: plot_rho_pha_pseudo(d)
%
% "d" is an MT data structure
%%
u = user_defaults;

%Calculate detailed statistics for all data
[s] = detailed_statistics(dobs,dpred);

%Pull a profile to plot the pseudo-section. "sidx" is stations indices
%included on profile and "rot_ang" is the direction of the normal to the
%profile direction
[sidx,midpoint,azimuth] = get_pseudo_section_indices(dobs);

rad = 180./pi;   

% Process cooordinates
if isfield(dobs,'loc') && ~all(dobs.origin==0) % here x is E-W, y is N-S 
%     lon_mean = mean(d.loc(sidx,2));  lat_mean = mean(d.loc(sidx,1)); % km
    lon_mean = midpoint(1);  lat_mean = midpoint(2); % km
    x = cos(lat_mean/rad)*111*(dobs.loc(sidx,2)-lon_mean);y = 111*(dobs.loc(sidx,1)-lat_mean); % km
else
    % if data from 2D inversion, then there is no reference to geographic
    % coordinates. just use x, y from inversion.. but need to switch x and
    % y for plotting
    x = dobs.y; y = dobs.x;    
end
N = length(sidx);

%% set up station indices
cd = cosd(azimuth);      sd = sind(azimuth);     R = [ cd, -sd ; sd, cd]; % this is a positive-counterclockwise rotation matrix
%Rotate station coordinates to get distance along profile - note
%stations rotated OPPOSITE of the profile azimuth so that x-coordinate
%will correspond to distance along the profile. does this only work if
%profile runs through center of station grid...?
x_rot = zeros(N,1); y_rot = zeros(size(x_rot));
for is=1:N
    loc = [x(is),y(is)];    loc = R*loc';
    x_rot(is) = loc(1);     y_rot(is)=loc(2);
end

% Add loop to put stations in order on monotonically increasing x_rot
[x_sort,index] = sort(x_rot,'ascend');
index = sidx(index);
%% plot off-diagonal components
%========================================================================
%Plot Real Zxy residuals
set_figure_size(1);
subplot(2,2,1)
[hp,vp,C] = fix_pcolor(x_sort,log10(dobs.T),squeeze(real(s.residuals.imp(:,2,index))));
pcolor(hp,vp,C)
hold on; axis ij
shading 'flat'
plot(x_sort,log10(dobs.T(1))-0.25,'kv','MarkerFaceColor','k')  %%%%changed
title('Real Z_{xy} ')
ylabel ('Period (s)')
axis([hp(1),hp(end), min(vp)-0.5 ,max(vp)])
colormap(gca,flipud(u.cmap))
caxis(u.residual_lim)
hcb = colorbar;
hcb.Label.String = 'Z residual';
set(gca,'Layer','top')

%========================================================================
%Plot Imag Zxy residuals
subplot(2,2,3)
[hp,vp,C] = fix_pcolor(x_sort,log10(dobs.T),squeeze(imag(s.residuals.imp(:,2,index))));
pcolor(hp,vp,C)
hold on; axis ij
shading 'flat'
plot(x_sort,log10(dobs.T(1))-0.25,'kv','MarkerFaceColor','k')
title('Imag Z_{xy} ')
xlabel('Distance (km)')
ylabel ('Period (s)')
axis([hp(1),hp(end), min(vp)-0.5 ,max(vp)])
colormap(gca,flipud(u.cmap))
caxis(u.residual_lim)
hcb = colorbar;
hcb.Label.String = 'Z residual';
set(gca,'Layer','top')

%========================================================================
%Plot Real Zyx residuals
subplot(2,2,2)
[hp,vp,C] = fix_pcolor(x_sort,log10(dobs.T),squeeze(real(s.residuals.imp(:,3,index))));
pcolor(hp,vp,C)
hold on; axis ij
shading 'flat'
plot(x_sort,log10(dobs.T(1))-0.25,'kv','MarkerFaceColor','k')
title('Real Z_{yx} ')   
ylabel ('Period (s)')
axis([hp(1),hp(end), min(vp)-0.5 ,max(vp)])
colormap(gca,flipud(u.cmap))
caxis(u.residual_lim)
hcb = colorbar;
hcb.Label.String = 'Z residual';
set(gca,'Layer','top')

%========================================================================
%Plot Imag Zyx residuals
subplot(2,2,4)
[hp,vp,C] = fix_pcolor(x_sort,log10(dobs.T),squeeze(imag(s.residuals.imp(:,3,index))));
pcolor(hp,vp,C)
hold on; axis ij
shading 'flat'
plot(x_sort,log10(dobs.T(1))-0.25,'kv','MarkerFaceColor','k')
title('Imag Z_{yx} ')
xlabel('Distance (km)')
ylabel ('Period (s)')
axis([hp(1),hp(end), min(vp)-0.5 ,max(vp)])
colormap(gca,flipud(u.cmap))
caxis(u.residual_lim)
hcb = colorbar;
hcb.Label.String = 'Z residual';
set(gca,'Layer','top')

annotation('textbox', [0 0.92 1 0.08], ...
'String', ['Impedance residuals | Profile azimuth = ',num2str(azimuth),char(176),' | Data rotated to ',num2str(unique(dobs.zrot)),char(176)], ...
'EdgeColor', 'none', ...
'HorizontalAlignment', 'center','FontSize',12,'FontWeight','bold')

print_figure(['misfit_stats_',dpred.niter],'Z_xy_yx_residual_pseudo'); %Save figure

%% plot diagonal components  
%========================================================================
%Plot Real Zxx residuals
set_figure_size(2);
subplot(2,2,1)
[hp,vp,C] = fix_pcolor(x_sort,log10(dobs.T),squeeze(real(s.residuals.imp(:,1,index))));
pcolor(hp,vp,C)
hold on; axis ij
shading 'flat'
plot(x_sort,log10(dobs.T(1))-0.25,'kv','MarkerFaceColor','k')  %%%%changed
title('Real Z_{xx} ')
ylabel ('Period (s)')
axis([hp(1),hp(end), min(vp)-0.5 ,max(vp)])
colormap(gca,flipud(u.cmap))
caxis(u.residual_lim)
hcb = colorbar;
hcb.Label.String = 'Z residual';
set(gca,'Layer','top')

%========================================================================
%Plot Imag Zxx residuals
subplot(2,2,3)
[hp,vp,C] = fix_pcolor(x_sort,log10(dobs.T),squeeze(imag(s.residuals.imp(:,1,index))));
pcolor(hp,vp,C)
hold on; axis ij
shading 'flat'
plot(x_sort,log10(dobs.T(1))-0.25,'kv','MarkerFaceColor','k')
title('Imag Z_{xx} ')
xlabel('Distance (km)')
ylabel ('Period (s)')
axis([hp(1),hp(end), min(vp)-0.5 ,max(vp)])
colormap(gca,flipud(u.cmap))
caxis(u.residual_lim)
hcb = colorbar;
hcb.Label.String = 'Z residual';
set(gca,'Layer','top')

%========================================================================
%Plot Real Zyy residuals
subplot(2,2,2)
[hp,vp,C] = fix_pcolor(x_sort,log10(dobs.T),squeeze(real(s.residuals.imp(:,4,index))));
pcolor(hp,vp,C)
hold on; axis ij
shading 'flat'
plot(x_sort,log10(dobs.T(1))-0.25,'kv','MarkerFaceColor','k')
title('Real Z_{yy} ')    
ylabel ('Period (s)')
axis([hp(1),hp(end), min(vp)-0.5 ,max(vp)])
colormap(gca,flipud(u.cmap))
caxis(u.residual_lim)
hcb = colorbar;
hcb.Label.String = 'Z residual';
set(gca,'Layer','top')

%========================================================================
%Plot Imag Zyy residuals
subplot(2,2,4)
[hp,vp,C] = fix_pcolor(x_sort,log10(dobs.T),squeeze(imag(s.residuals.imp(:,4,index))));
pcolor(hp,vp,C)
hold on; axis ij
shading 'flat'
plot(x_sort,log10(dobs.T(1))-0.25,'kv','MarkerFaceColor','k')
title('Imag Z_{yy} ')
xlabel('Distance (km)')
ylabel ('Period (s)')
axis([hp(1),hp(end), min(vp)-0.5 ,max(vp)])
colormap(gca,flipud(u.cmap))
caxis(u.residual_lim)
hcb = colorbar;
hcb.Label.String = 'Z residual';
set(gca,'Layer','top')

annotation('textbox', [0 0.92 1 0.08], ...
'String', ['Impedance residuals | Profile azimuth = ',num2str(azimuth),char(176),' | Data rotated to ',num2str(unique(dobs.zrot)),char(176)], ...
'EdgeColor', 'none', ...
'HorizontalAlignment', 'center','FontSize',12,'FontWeight','bold')

print_figure(['misfit_stats_',dpred.niter],'Z_xx_yy_residual_pseudo'); %Save figure
%% plot tipper    

if ~all(all(all(isnan(s.residuals.tip)))) % tipper data were inverted
    
    %========================================================================
    %Plot Real Tzx residuals
    set_figure_size(3);
    subplot(2,2,1)
    [hp,vp,C] = fix_pcolor(x_sort,log10(dobs.T),squeeze(real(s.residuals.tip(:,1,index))));
    pcolor(hp,vp,C)
    hold on; axis ij
    shading 'flat'
    plot(x_sort,log10(dobs.T(1))-0.25,'kv','MarkerFaceColor','k')  %%%%changed
    title('Real T_{zx} ')
    ylabel ('Period (s)')
    axis([hp(1),hp(end), min(vp)-0.5 ,max(vp)])
    colormap(gca,flipud(u.cmap))
    caxis(u.residual_lim)
    hcb = colorbar;
    hcb.Label.String = 'Tipper residual';
    set(gca,'Layer','top')
    
    %========================================================================
    %Plot Imag Tzx residuals
    subplot(2,2,3)
    [hp,vp,C] = fix_pcolor(x_sort,log10(dobs.T),squeeze(imag(s.residuals.tip(:,1,index))));
    pcolor(hp,vp,C)
    hold on; axis ij
    shading 'flat'
    plot(x_sort,log10(dobs.T(1))-0.25,'kv','MarkerFaceColor','k')  %%%%changed
    title('Imag T_{zx} ')
    xlabel('Distance (km)')
    ylabel ('Period (s)')
    axis([hp(1),hp(end), min(vp)-0.5 ,max(vp)])
    colormap(gca,flipud(u.cmap))
    caxis(u.residual_lim)
    hcb = colorbar;
    hcb.Label.String = 'Tipper residual';
    set(gca,'Layer','top')
%     text(x_sort(1),log10(dobs.T(1))-0.6,strrep(dobs.site(index(1)),'_','\_'),'rotation',90)
%     text(x_sort(end),log10(dobs.T(1))-0.6,strrep(dobs.site(index(end)),'_','\_'),'rotation',90)
    
    %========================================================================
    %Plot Real Tzy residuals
    subplot(2,2,2)
    [hp,vp,C] = fix_pcolor(x_sort,log10(dobs.T),squeeze(real(s.residuals.tip(:,2,index))));
    pcolor(hp,vp,C)
    hold on; axis ij
    shading 'flat'
    plot(x_sort,log10(dobs.T(1))-0.25,'kv','MarkerFaceColor','k')  %%%%changed
    title('Real T_{zy} ')
    ylabel ('Period (s)')
    axis([hp(1),hp(end), min(vp)-0.5 ,max(vp)])
    colormap(gca,flipud(u.cmap))
    caxis(u.residual_lim)
    hcb = colorbar;
    hcb.Label.String = 'Tipper residual';
    set(gca,'Layer','top')
    
    %========================================================================
    %Plot Imag Tzy residuals
    subplot(2,2,4)
    [hp,vp,C] = fix_pcolor(x_sort,log10(dobs.T),squeeze(imag(s.residuals.tip(:,2,index))));
    pcolor(hp,vp,C)
    hold on; axis ij
    shading 'flat'
    plot(x_sort,log10(dobs.T(1))-0.25,'kv','MarkerFaceColor','k')  %%%%changed
    title('Imag T_{zy} ')
    xlabel('Distance (km)')
    ylabel ('Period (s)')
    axis([hp(1),hp(end), min(vp)-0.5 ,max(vp)])
    colormap(gca,flipud(u.cmap))
    caxis(u.residual_lim)
    hcb = colorbar;
    hcb.Label.String = 'Tipper residual';
    set(gca,'Layer','top')
%     text(x_sort(1),log10(dobs.T(1))-0.6,strrep(dobs.site(index(1)),'_','\_'),'rotation',90)
%     text(x_sort(end),log10(dobs.T(1))-0.6,strrep(dobs.site(index(end)),'_','\_'),'rotation',90)
    
    annotation('textbox', [0 0.92 1 0.08], ...
    'String', ['Tipper residuals | Profile azimuth = ',num2str(azimuth),char(176),' | Data rotated to ',num2str(unique(dobs.zrot)),char(176)], ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center','FontSize',12,'FontWeight','bold')
    
    print_figure(['misfit_stats_',dpred.niter],'tipper_residual_pseudo'); %Save figure
    
end

end % end function
    