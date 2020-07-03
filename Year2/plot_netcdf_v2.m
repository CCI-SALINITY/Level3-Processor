clear all;
close all;

%file='/net/nfs/home/chakroun/Q2011238.L3m_DAY_SCIA_V5.0_SSS_1deg';
file='/net/nfs/tmp15/chakroun/L3_output/L3C_nc/monthly/ESACCI-SEASURFACESALINITY-L3C-SSS-SMOSSMAPAQUARIUS_Monthly_Centred_15Day_25km-20150515-fv1.0.nc';

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

subplot(4,3,1)
pcolor(longitude,latitude,squeeze(SSS_smos)')
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('a. SSS corrected smos monthly')

subplot(4,3,2)
pcolor(longitude,latitude,squeeze(SSS_smap)')
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('b. SSS corrected smap monthly')

subplot(4,3,3)
pcolor(longitude,latitude,squeeze(SSS_aquarius)')
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('c. SSS corrected aquarius monthly')

subplot(3,3,4)
pcolor(longitude,latitude,squeeze(SSS_smos+SSS_smos_bias)')
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('d. SSS biased smos monthly')

subplot(3,3,5)
pcolor(longitude,latitude,squeeze(SSS_smap+SSS_smap_bias)')
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('e. SSS biased smap monthly')

subplot(3,3,6)
pcolor(longitude,latitude,squeeze(SSS_aquarius+SSS_aquarius_bias)')
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('f. SSS biased aquarius monthly')

figure(2)

subplot(3,3,1)
pcolor(longitude,latitude,squeeze(SSS_smos)')
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('a. SSS corrected smos monthly')

subplot(3,3,2)
pcolor(longitude,latitude,squeeze(SSS_smap)')
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('b. SSS corrected smap monthly')

subplot(3,3,3)
pcolor(longitude,latitude,squeeze(SSS_aquarius)')
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('c. SSS corrected aquarius monthly')

subplot(3,3,4)
pcolor(longitude,latitude,squeeze(SSS_smos+SSS_smos_bias)')
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('d. SSS biased smos monthly')

subplot(3,3,5)
pcolor(longitude,latitude,squeeze(SSS_smap+SSS_smap_bias)')
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('e. SSS biased smap monthly')

subplot(3,3,6)
pcolor(longitude,latitude,squeeze(SSS_aquarius+SSS_aquarius_bias)')
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('f. SSS biased aquarius monthly')

%%%on filtre donnees



II=[];
II=find(sss_qc_smos==1);
SSS_smos(II)=nan;
II=[];
II=find(sss_qc_smap==1);
SSS_smap(II)=nan;
II=[];
II=find(sss_qc_aquarius==1);
SSS_aquarius(II)=nan;

figure(1)

subplot(3,3,7)
pcolor(longitude,latitude,squeeze(SSS_smos)')
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('g. SSS corrected filtred smos monthly')

subplot(3,3,8)
pcolor(longitude,latitude,squeeze(SSS_smap)')
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('h. SSS corrected filtred smap monthly')

subplot(3,3,9)
pcolor(longitude,latitude,squeeze(SSS_aquarius)')
hold on
plot(long,lat)
shading flat
box on
colorbar
caxis([32 38])
set(gca,'Fontsize',14)
title('i. SSS corrected filtred aquarius monthly')

figure(2) 

subplot(3,3,7)
pcolor(longitude,latitude,squeeze(SSS_smos)')
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('g. SSS corrected filtred smos monthly')

subplot(3,3,8)
pcolor(longitude,latitude,squeeze(SSS_smap)')
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('h. SSS corrected filtred smap monthly')

subplot(3,3,9)
pcolor(longitude,latitude,squeeze(SSS_aquarius)')
hold on
plot(long,lat)
shading flat
box on
colorbar
set(gca,'Fontsize',14)
title('i. SSS corrected filtred aquarius monthly')

