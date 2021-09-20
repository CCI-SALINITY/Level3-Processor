clear all;
close all;

%file='/net/nfs/home/chakroun/Q2011238.L3m_DAY_SCIA_V5.0_SSS_1deg';
file='J:\SSS\CCI\2021\productL3_v3.2\weekly\ESACCI-SEASURFACESALINITY-L3C-SSS-SMOSSMAPAQUARIUS_7Day_runningmean_Daily_25km-20150526-fv3.2.nc';

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

figure(1)

subplot(2,3,1)
pcolor(longitude,latitude,squeeze(SSS_smos)')
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('a. SSS corrected smos weekly')

subplot(2,3,2)
pcolor(longitude,latitude,squeeze(SSS_smap)')
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('b. SSS corrected smap weekly')

subplot(2,3,3)
pcolor(longitude,latitude,squeeze(SSS_aquarius)')
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('c. SSS corrected aquarius weekly')

subplot(2,3,4)
pcolor(longitude,latitude,squeeze(SSS_smos+SSS_smos_bias)')
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('d. SSS biased smos weekly')

subplot(2,3,5)
pcolor(longitude,latitude,squeeze(SSS_smap+SSS_smap_bias)')
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('e. SSS biased smap weekly')

subplot(2,3,6)
pcolor(longitude,latitude,squeeze(SSS_aquarius)'+squeeze(SSS_aquarius_bias)')
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('f. SSS biased aquarius weekly')


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
caxis([-2 4])

subplot(3,3,2)
pcolor(longitude,latitude,squeeze(Noutliers_L4_smap'))
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('b. Number of L4 outliers smap')
caxis([-2 4])

subplot(3,3,3)
pcolor(longitude,latitude,squeeze(Noutliers_L4_aquarius'))
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('c. Number of L4 outliers aquarius')
caxis([-2 4])

subplot(3,3,4)
pcolor(longitude,latitude,squeeze(Total_nobs_smos'))
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('d. Number of observations smos')
caxis([-4 20])

subplot(3,3,5)
pcolor(longitude,latitude,squeeze(Total_nobs_smap'))
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('e. Number of observations smap')
caxis([-4 20])

subplot(3,3,6)
pcolor(longitude,latitude,squeeze(Total_nobs_aquarius'))
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('f. Number of observations aquarius')
caxis([-4 20])

subplot(3,3,7)
pcolor(longitude,latitude,squeeze(sss_qc_smos'))
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('g. Quality flag smos')
caxis([-2 1])

subplot(3,3,8)
pcolor(longitude,latitude,squeeze(sss_qc_smap'))
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('h. Quality flag smap')
caxis([-2 1])

subplot(3,3,9)
pcolor(longitude,latitude,squeeze(sss_qc_aquarius'))
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('i. Quality flag aquarius')
caxis([-2 1])


