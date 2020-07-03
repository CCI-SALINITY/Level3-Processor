clear all;
close all;

file='/net/nfs/tmp15/chakroun/L3_output/L3C_nc/weekly/ESACCI-SEASURFACESALINITY-L3C-SSS-SMOSSMAPAQUARIUS_7Day_runningmean_Daily_25km-20150601-fv2.3.nc';

nc=netcdf.open(file,'nowrite');

lat_ID=netcdf.inqVarID(nc,'lat');
latitude=double(netcdf.getVar(nc,lat_ID));

lon_ID=netcdf.inqVarID(nc,'lon');
longitude=double(netcdf.getVar(nc,lon_ID));

SSSsmos_ID=netcdf.inqVarID(nc,'sss_smos');
SSS_smos=double(netcdf.getVar(nc,SSSsmos_ID));

SSSsmap_ID=netcdf.inqVarID(nc,'sss_smap');
SSS_smap=double(netcdf.getVar(nc,SSSsmap_ID));

SSSaquarius_ID=netcdf.inqVarID(nc,'sss_aquarius');
SSS_aquarius=double(netcdf.getVar(nc,SSSaquarius_ID));

SSSsmos_ID=netcdf.inqVarID(nc,'sss_smos_random_error');
SSS_smos_randomerror=double(netcdf.getVar(nc,SSSsmos_ID));

SSSsmap_ID=netcdf.inqVarID(nc,'sss_smap_random_error');
SSS_smap_randomerror=double(netcdf.getVar(nc,SSSsmap_ID));

SSSaquarius_ID=netcdf.inqVarID(nc,'sss_aquarius_random_error');
SSS_aquarius_randomerror=double(netcdf.getVar(nc,SSSaquarius_ID));

SSSsmos_ID=netcdf.inqVarID(nc,'sss_smos_bias');
SSS_smos_bias=double(netcdf.getVar(nc,SSSsmos_ID));

SSSsmap_ID=netcdf.inqVarID(nc,'sss_smap_bias');
SSS_smap_bias=double(netcdf.getVar(nc,SSSsmap_ID));

SSSaquarius_ID=netcdf.inqVarID(nc,'sss_aquarius_bias');
SSS_aquarius_bias=double(netcdf.getVar(nc,SSSaquarius_ID));

SSSsmos_ID=netcdf.inqVarID(nc,'sss_qc_smos');
sss_qc_smos=double(netcdf.getVar(nc,SSSsmos_ID));

SSSsmap_ID=netcdf.inqVarID(nc,'sss_qc_smap');
sss_qc_smap=double(netcdf.getVar(nc,SSSsmap_ID));

SSSaquarius_ID=netcdf.inqVarID(nc,'sss_qc_aquarius');
sss_qc_aquarius=double(netcdf.getVar(nc,SSSaquarius_ID));

SSSsmos_ID=netcdf.inqVarID(nc,'Noutliers_L4_smos');
Noutliers_L4_smos=double(netcdf.getVar(nc,SSSsmos_ID));

SSSsmap_ID=netcdf.inqVarID(nc,'Noutliers_L4_smap');
Noutliers_L4_smap=double(netcdf.getVar(nc,SSSsmap_ID));

SSSaquarius_ID=netcdf.inqVarID(nc,'Noutliers_L4_aquarius');
Noutliers_L4_aquarius=double(netcdf.getVar(nc,SSSaquarius_ID));

SSSsmos_ID=netcdf.inqVarID(nc,'Total_nobs_smos');
Total_nobs_smos=double(netcdf.getVar(nc,SSSsmos_ID));

SSSsmap_ID=netcdf.inqVarID(nc,'Total_nobs_smap');
Total_nobs_smap=double(netcdf.getVar(nc,SSSsmap_ID));

SSSaquarius_ID=netcdf.inqVarID(nc,'Total_nobs_aquarius');
Total_nobs_aquarius=double(netcdf.getVar(nc,SSSaquarius_ID));


load coast;
if true
figure(1)

subplot(4,3,1)
pcolor(longitude,latitude,squeeze(SSS_smos'))
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('a. SSS smos monthly')

subplot(4,3,2)
pcolor(longitude,latitude,squeeze(SSS_smap'))
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('b. SSS smap monthly')

subplot(4,3,3)
pcolor(longitude,latitude,squeeze(SSS_aquarius'))
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('c. SSS aquarius monthly')

II=[];
II=find(sss_qc_smos==1);
SSS_smos(II)=nan;
II=[];
II=find(sss_qc_smap==1);
SSS_smap(II)=nan;
II=[];
II=find(sss_qc_aquarius==1);
SSS_aquarius(II)=nan;

subplot(4,3,4)
pcolor(longitude,latitude,squeeze(SSS_smos'))
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('a. SSS smos filtred monthly')

subplot(4,3,5)
pcolor(longitude,latitude,squeeze(SSS_smap'))
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('b. SSS smap filtred monthly')

subplot(4,3,6)
pcolor(longitude,latitude,squeeze(SSS_aquarius'))
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('c. SSS aquarius filtred monthly')

subplot(4,3,7)
pcolor(longitude,latitude,squeeze(SSS_smos_bias'))
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([-2 2])
set(gca,'Fontsize',14)
title('d. SSS bias smos monthly')

subplot(4,3,8)
pcolor(longitude,latitude,squeeze(SSS_smap_bias'))
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([-2 2])
set(gca,'Fontsize',14)
title('e. SSS bias smap monthly')

subplot(4,3,9)
pcolor(longitude,latitude,squeeze(SSS_aquarius_bias'))
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([-2 2])
set(gca,'Fontsize',14)
title('f. SSS bias aquarius monthly')

subplot(4,3,10)
pcolor(longitude,latitude,squeeze(SSS_smos_randomerror'))
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([0 0.5])
set(gca,'Fontsize',14)
title('g. SSS std smos monthly')

subplot(4,3,11)
pcolor(longitude,latitude,squeeze(SSS_smap_randomerror'))
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([0 0.5])
set(gca,'Fontsize',14)
title('h. SSS std smap monthly')

subplot(4,3,12)
pcolor(longitude,latitude,squeeze(SSS_aquarius_randomerror'))
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([0 0.5])
set(gca,'Fontsize',14)
title('i. SSS std aquarius monthly')
end
Noutliers_L4_smos(Noutliers_L4_smos<-100)=nan;
Noutliers_L4_smap(Noutliers_L4_smap<-100)=nan;
Noutliers_L4_aquarius(Noutliers_L4_aquarius<-100)=nan;

Total_nobs_smos(Total_nobs_smos<-100)=nan;
Total_nobs_smap(Total_nobs_smap<-100)=nan;
Total_nobs_aquarius(Total_nobs_aquarius<-100)=nan;

sss_qc_smos(sss_qc_smos<-100)=nan;
sss_qc_smap(sss_qc_smap<-100)=nan;
sss_qc_aquarius(sss_qc_aquarius<-100)=nan;

figure(2)

subplot(3,3,1)
pcolor(longitude,latitude,squeeze(Noutliers_L4_smos'))
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('a. Number of L4 outliers smos')
caxis([0 4])

subplot(3,3,2)
pcolor(longitude,latitude,squeeze(Noutliers_L4_smap'))
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('b. Number of L4 outliers smap')
caxis([0 4])

subplot(3,3,3)
pcolor(longitude,latitude,squeeze(Noutliers_L4_aquarius'))
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('c. Number of L4 outliers aquarius')
caxis([0 4])

subplot(3,3,4)
pcolor(longitude,latitude,squeeze(Total_nobs_smos'))
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('d. Number of observations smos')
caxis([0 20])

subplot(3,3,5)
pcolor(longitude,latitude,squeeze(Total_nobs_smap'))
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('e. Number of observations smap')
caxis([0 20])

subplot(3,3,6)
pcolor(longitude,latitude,squeeze(Total_nobs_aquarius'))
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('f. Number of observations aquarius')
caxis([0 20])

subplot(3,3,7)
pcolor(longitude,latitude,squeeze(sss_qc_smos'))
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('g. Quality flag smos')
caxis([-1 1])

subplot(3,3,8)
pcolor(longitude,latitude,squeeze(sss_qc_smap'))
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('h. Quality flag smap')
caxis([-1 1])

subplot(3,3,9)
pcolor(longitude,latitude,squeeze(sss_qc_aquarius'))
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('i. Quality flag aquarius')
caxis([-1 1])

saveas(figure(2),'L3Cnoutliers01062015','png')
