clear all;
close all;

avg=7;
input_dir=('/net/nfs/tmp15/chakroun/L3_output/Level3_intermediate/SSS_AQUARIUS_corrected/');
dirL2c=dir(input_dir);
load ('/net/nfs/home/chakroun/CCI_SSS/production_donnees/auxilary/lsc_flag_ease.mat') %fichier flag lsc
load('/net/nfs/home/chakroun/CCI_SSS/production_donnees/auxilary/latlon_ease.mat') %fichier grille
nlon=length(lon_ease);
nlat=length(lat_ease);
output_dir=('/net/nfs/tmp15/chakroun/L3_output/Level3_intermediate/SSS_AQUARIUS_merged/weekly/');
load ('/net/nfs/tmp15/tmpJLV/packCCI/CCI_soft_year2/aux_files/ERR_REP_50km1d_50km30d_smooth.mat') %variabilite hebdomadaire
L4_dir=('/net/nfs/tmp15/tmpJLV/CCI/month_q2/');
%%%%%%%%%%%%%%%%compute and save 1st week%%%%%%%%%%%%%%%

YYYY0=str2num(dirL2c(3).name(end-13:end-10));
MM0=str2num(dirL2c(3).name(end-9:end-8));
jour0=str2num(dirL2c(3).name(end-7:end-6));
n0=datenum(YYYY0,MM0,jour0);

YYYYend=str2num(dirL2c(end-1).name(end-13:end-10));
MMend=str2num(dirL2c(end-1).name(end-9:end-8));
jourend=str2num(dirL2c(end-1).name(end-7:end-6));
nend=datenum(YYYYend,MMend,jourend);

njours=nend-avg+1-n0

for ii=850:njours%toutes les semaines possibles entre t0 et end
	SSS_corr=nan(avg*2,nlon,nlat);
	eSSS0=nan(avg*2,nlon,nlat);
	totalcorrection=nan(avg*2,nlon,nlat);
	noutliers_L4_aquarius=zeros(nlon,nlat);
	Date_kk=datestr(n0+ii-1:n0+ii+avg-1,30);%les dates d une semaine	
	cmpt=0;
	for uu=1:7
		list=dir([input_dir,'aquariusL3corrected_',Date_kk(uu,1:8),'*.mat']);
		if (length(list)>0)
			for ff=1:length(list)
				SSS0=[];
				eSSS0=[];

				input_file=([input_dir,list(ff).name])	;
				load(input_file);
				%filtrage glace, cote

				II=[];
				II=find((lsc_flag==1)|(totalcorrection>20));

				SSS_corr(II)=nan;
				totalcorrection(II)=nan;
				SSS_random(II)=nan;
				cmpt=cmpt+1;

				Bias(cmpt,:,:)=-totalcorrection;
				SSScorrigee(cmpt,:,:)=SSS_corr;
				randomerror(cmpt,:,:)=eSSS0;
				noutliers_L4_aquarius=noutliers_L4_aquarius+sss_qc_aquarius;
			end
		end
	end
	if (cmpt>0)
		%filtre 3 sigma

		%keyboard%dbcont%dbquit

		SSS_moy=squeeze(nanmedian(SSScorrigee));%temps,lon, lat
		SSS_moyenne=nan*ones(size(randomerror));

		for kk=1:length(SSS_moyenne(:,1,1))
			SSS_moyenne(kk,:,:)=SSS_moy;
		end

		KK=find(abs(SSScorrigee-SSS_moyenne)>3*randomerror);

		SSScorrigee(KK)=nan;
		randomerror(KK)=nan;	
		Bias(KK)=nan;	

		%calcul random error
		ind=find(isnan(SSScorrigee));
		nobs_aquarius=zeros(nlon,nlat);
		for nln=1:nlon
			for nlt=1:nlat
				UU=[];
				UU=find(SSScorrigee(:,nln,nlt)>=0);
				nobs_aquarius(nln,nlt)=length(UU);
			end
		end
		%kind=find(isnan(randomerror));
		%length(kind)-length(ind)
		SSScorrigee(ind)=NaN;
		randomerror(ind)=NaN;
		Bias(ind)=NaN;

		var_int=nansum(1./randomerror.^2,1);
		II=[];
		II=find(var_int==0);
		var_int(II)=nan;
		SSS_aquarius_random=squeeze(sqrt(1./var_int));

		%calcul SSS

		var_int=[];
		var_int=nansum(SSScorrigee./randomerror.^2,1);
		var_int(II)=nan;
		SSS_aquarius=squeeze(var_int).*SSS_aquarius_random.^2;

		%calcul biais SSS

		var_int=[];
		var_int=nansum(Bias./randomerror.^2,1);
		var_int(II)=nan;
		SSS_aquarius_bias=squeeze(var_int).*SSS_aquarius_random.^2;

		ncentral=(n0+ii+2);
		Acentral=datestr(ncentral,30);
		Datecentral=Acentral(1:8);

		%estimer sss_qc_aquarius

		yyyy=Acentral(1:4);
		mm=Acentral(5:6);

		L4_file=([L4_dir,'ESACCI-SEASURFACESALINITY-L4-SSS-MERGED_OI_Monthly_CENTRED_15Day_25km-',yyyy,mm,'01-fv03.nc']);
		nc=netcdf.open(L4_file,'nowrite');

		sss_ID=netcdf.inqVarID(nc,'sss');
		sss_ref_L4=double(netcdf.getVar(nc,sss_ID));

		ssserror_ID=netcdf.inqVarID(nc,'sss_random_error');
		sss_erreur_L4=double(netcdf.getVar(nc,ssserror_ID));

		sss_qc_aquarius=nan(nlon,nlat);
		hebdo=squeeze(errrepres(:,:,str2num(mm)));
		sigma=sqrt(SSS_aquarius_random.^2+hebdo.^2+sss_erreur_L4.^2);

		JJ=[];
		JJ=find(SSS_aquarius>0);
		sss_qc_aquarius(JJ)=0;

		II=[];
		II=find(abs(SSS_aquarius-sss_ref_L4)>3*sigma);
		length(II)

		sss_qc_aquarius(II)=1;

		output_file=([output_dir,'aquariusL3_weeklyaveraged_',Datecentral,'centred'])
		save(output_file,'SSS_aquarius','SSS_aquarius_random','SSS_aquarius_bias','nobs_aquarius','sss_qc_aquarius','noutliers_L4_aquarius') 
		netcdf.close(nc)
	end
end

load coast 

figure(10)
subplot(2,2,1)
pcolor(lon_ease,lat_ease,SSS_aquarius')
hold on
plot(long,lat)
shading flat
colorbar
caxis([32 38])
title('a. SSS')

subplot(2,2,2)
pcolor(lon_ease,lat_ease,SSS_aquarius_random')
shading flat
hold on
plot(long,lat)
colorbar
caxis([0 2])
title('b. SSS sigma')

II=[];
II=find(sss_qc_aquarius==1);
SSS_aquarius(II)=nan;

subplot(2,2,3)
pcolor(lon_ease,lat_ease,SSS_aquarius')
hold on
plot(long,lat)
shading flat
colorbar
caxis([32 38])
title('c. SSS filtre')

subplot(2,2,4)
pcolor(lon_ease,lat_ease,noutliers_L4_aquarius')
shading flat
hold on
plot(long,lat)
colorbar
caxis([0 2])
title('d. noutliers')

