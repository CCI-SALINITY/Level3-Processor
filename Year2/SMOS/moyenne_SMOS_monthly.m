clear all;
close all;

avg=31;
load('/net/nfs/home/chakroun/CCI_SSS/Level2/aux_files/latlon_ease.mat') %fichier grille
load ('/net/nfs/home/chakroun/CCI_SSS/Level2/aux_files/lsc_flag_ease.mat') %fichier flag lsc
load ('/net/nfs/tmp15/tmpJLV/packCCI/CCI_soft_year2/aux_files/ERR_REP_50km1d_50km30d_smooth.mat') %variabilite hebdomadaire

nlon=length(lon_ease);
nlat=length(lat_ease);

input_dir=('/net/nfs/tmp15/chakroun/L2_output/Level2_intermediate/Totallycorrected_smos/');
dirL2c=dir(input_dir);
output_dir=('/net/nfs/tmp15/chakroun/L3_output/Level3_intermediate/SSS_SMOS_merged/monthly/');
L4_dir=('/net/nfs/tmp15/tmpJLV/CCI/month_q2/');

%%%%%%%%%%%%%%%%compute and save 1st week%%%%%%%%%%%%%%%

YYYY0=str2num(dirL2c(4).name(17:20));
MM0=str2num(dirL2c(4).name(end-9:end-8));
jour0=str2num(dirL2c(4).name(end-7:end-6));
n0=datenum(YYYY0,MM0,jour0);

YYYYend=str2num(dirL2c(end).name(17:20));
MMend=str2num(dirL2c(end).name(end-9:end-8));
jourend=str2num(dirL2c(end).name(end-7:end-6));
nend=datenum(YYYYend,MMend,jourend);

njours=nend-avg+1-n0;

%creer liste de dates 1er et 15 de chaque mois


cmpt1=1;
cmpt15=2;
for yy=1:YYYYend-YYYY0+1
	for MM=1:12
		YY=yy+YYYY0-1;

		ndate(cmpt1)=datenum(YY,MM,1);
		ndate(cmpt15)=datenum(YY,MM,15);

		cmpt1=cmpt1+2;
		cmpt15=cmpt15+2;
	end
end

ndate=ndate(find((ndate<=nend)&(ndate>=n0)));

for ii=1:length(ndate)% tous les 1er et 15 du mois
	SSScorrigee=nan(avg*2,nlon,nlat);
	randomerror=nan(avg*2,nlon,nlat);
	bias=nan(avg*2,nlon,nlat);
	noutliers_L4_smos=zeros(nlon,nlat);
	Date_kk=[];
	Date_kk=datestr(ndate(ii)-15:ndate(ii)+15,30);%les dates d un mois
	cmpt=0;
	for uu=1:length(Date_kk)
		list=dir([input_dir,'smosL2corrected_',Date_kk(uu,1:8),'_*.mat']);
		if (length(list)>0)
			for ff=1:length(list)
				SSS_corr=[];
				totalcorrection=[];
				SSS_random=[];
				Dg_Suspect_ice0=[];

				cmpt=cmpt+1;

				input_file=([input_dir,list(ff).name])	
				load(input_file);

				%filtrage glace, cote

				II=[];
				II=find((Dg_Suspect_ice0>0)|(lsc_flag==1)|(WS0>16)|(abs(Acard_mod-Acard)>2)|(flag_many_outlier==1));
				
				SSS_corr(II)=nan;
				totalcorrection(II)=nan;
				SSS_random(II)=nan;

				SSScorrigee(cmpt,:,:)=SSS_corr;
				bias(cmpt,:,:)=-totalcorrection;
				randomerror(cmpt,:,:)=SSS_random;
				noutliers_L4_smos=noutliers_L4_smos+sss_qc_smos;
			end
		end
	end
	if (cmpt>0)
		%nobs_total
		nobs_smos=zeros(nlon,nlat);
		for nln=1:nlon
			for nlt=1:nlat
				UU=[];
				UU=find(SSScorrigee(:,nln,nlt)>=0);
				nobs_smos(nln,nlt)=length(UU);
			end
		end

		%filtre 3 sigma

		%keyboard%dbcont%dbquit

		SSS_moy=squeeze(nanmedian(SSScorrigee));%temps,lon, lat
		SSS_moyenne=nan*ones(size(randomerror));

		for kk=1:length(SSS_moyenne(:,1,1))
			SSS_moyenne(kk,:,:)=SSS_moy;
		end

		KK=find(abs(SSScorrigee-SSS_moyenne)>3*randomerror);

		SSScorrigee(KK)=nan;
		bias(KK)=nan;	
		randomerror(KK)=nan;	

		%calcul random error
		ind=find(isnan(SSScorrigee));
		%kind=find(isnan(randomerror));
		%length(kind)-length(ind)
		SSScorrigee(ind)=NaN;
		randomerror(ind)=NaN;
		bias(ind)=NaN;

		var_int=nansum(1./randomerror.^2,1);
		II=[];
		II=find(var_int==0);
		var_int(II)=nan;
		SSS_smos_random=squeeze(sqrt(1./var_int));

		%calcul SSS

		var_int=[];
		var_int=nansum(SSScorrigee./randomerror.^2,1);
		var_int(II)=nan;
		SSS_smos=squeeze(var_int).*SSS_smos_random.^2;

		%calcul biais

		%var_int=[];
		var_int=nansum(bias./randomerror.^2,1);
		%var_int(II)=nan;
		SSS_smos_bias=squeeze(var_int).*SSS_smos_random.^2;

		ncentral=(ndate(ii));
		Acentral=datestr(ncentral,30);
		Datecentral=Acentral(1:8);

		%estimer sss_qc_smos

		yyyy=Acentral(1:4);
		mm=Acentral(5:6);

		L4_file=([L4_dir,'ESACCI-SEASURFACESALINITY-L4-SSS-MERGED_OI_Monthly_CENTRED_15Day_25km-',yyyy,mm,'01-fv03.nc']);
		nc=netcdf.open(L4_file,'nowrite');

		sss_ID=netcdf.inqVarID(nc,'sss');
		sss_ref_L4=double(netcdf.getVar(nc,sss_ID));

		ssserror_ID=netcdf.inqVarID(nc,'sss_random_error');
		sss_erreur_L4=double(netcdf.getVar(nc,ssserror_ID));

		sss_qc_smos=nan(nlon,nlat);
		sigma=sqrt(SSS_smos_random.^2+sss_erreur_L4.^2);

		JJ=[];
		JJ=find(SSS_smos>0);
		sss_qc_smos(JJ)=0;

		II=[];
		II=find(abs(SSS_smos-sss_ref_L4)>3*sigma);

		sss_qc_smos(II)=1;

		output_file=([output_dir,'smosL3_monthlyaveraged_',Datecentral,'centred']);
		save(output_file,'SSS_smos','SSS_smos_bias','SSS_smos_random','nobs_smos','noutliers_L4_smos','sss_qc_smos') 
		netcdf.close(nc)
	end
end

if false

	load coast 

	figure(10)
	subplot(2,2,1)
	pcolor(lon_ease,lat_ease,SSS_smos')
	hold on
	plot(long,lat)
	shading flat
	colorbar
	caxis([32 38])
	title('a. SSS')

	subplot(2,2,2)
	pcolor(lon_ease,lat_ease,SSS_smos_random')
	shading flat
	hold on
	plot(long,lat)
	colorbar
	caxis([0 2])
	title('b. SSS sigma')

	II=[];
	II=find(sss_qc_smos==1);
	SSS_smos(II)=nan;

	subplot(2,2,3)
	pcolor(lon_ease,lat_ease,SSS_smos')
	hold on
	plot(long,lat)
	shading flat
	colorbar
	caxis([32 38])
	title('c. SSS bias')

	subplot(2,2,4)
	pcolor(lon_ease,lat_ease,nobs_smos')
	hold on
	plot(long,lat)
	shading flat
	colorbar
	caxis([0 14])
	title('d. SSS count')
end
