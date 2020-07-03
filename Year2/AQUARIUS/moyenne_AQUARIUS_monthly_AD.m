clear all;
close all;

avg=31;
input_dir=('/net/nfs/tmp15/chakroun/L3_output/Level3_intermediate/SSS_AQUARIUS_corrected/');
load('/net/nfs/home/chakroun/CCI_SSS/production_donnees/auxilary/latlon_ease.mat') %fichier grille
load('/net/nfs/home/chakroun/CCI_SSS/production_donnees/auxilary/lsc_flag_ease.mat') %fichier flag lsc
dirL2c=dir(input_dir);
output_dir=('/net/nfs/tmp15/chakroun/L3_output/Level3_intermediate/SSS_AQUARIUS_merged/');
load ('/net/nfs/tmp15/tmpJLV/packCCI/CCI_soft_year2/aux_files/ERR_REP_50km1d_50km30d_smooth.mat') %variabilite hebdomadaire
L4_dir=('/net/nfs/tmp15/tmpJLV/CCI/month_q2/');

nlon=length(lon_ease);
nlat=length(lat_ease);

%%%%%%%%%%%%%%%%compute and save 1st week%%%%%%%%%%%%%%%

YYYY0=str2num(dirL2c(3).name(end-13:end-10));
MM0=str2num(dirL2c(3).name(end-9:end-8));
jour0=str2num(dirL2c(3).name(end-7:end-6));
n0=datenum(YYYY0,MM0,jour0);

YYYYend=str2num(dirL2c(end-1).name(end-13:end-10));
MMend=str2num(dirL2c(end-1).name(end-9:end-8));
jourend=str2num(dirL2c(end-1).name(end-7:end-6));
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

for orb=['A' 'D']
	for ii=1:length(ndate)%toutes les semaines possibles entre t0 et end
		SSS_corr=nan(avg,nlon,nlat);
		eSSS0=nan(avg,nlon,nlat);
		totalcorrection=nan(avg,nlon,nlat);
		noutliers_L4_aquarius=zeros(nlon,nlat);
		Date_kk=[];
		Date_kk=datestr(ndate(ii)-15:ndate(ii)+15,30);%les dates d un mois
		cmpt=0;
		for uu=1:length(Date_kk)
			fic=dir([input_dir,'aquariusL3corrected_',Date_kk(uu,1:8),'_',orb,'.mat']);
			if (length(fic)>0)
				cmpt=cmpt+1;
				SSS0=[];
				eSSS0=[];

				input_file=([input_dir,fic.name]);	
				load(input_file);

				%filtrage glace, cote

				II=[];
				II=find((lsc_flag==1)|(totalcorrection>20));
				
				SSS_corr(II)=nan;
				totalcorrection(II)=nan;
				SSS_random(II)=nan;

				Bias(uu,:,:)=-totalcorrection;
				SSScorrigee(uu,:,:)=SSS_corr;
				randomerror(uu,:,:)=eSSS0;
				noutliers_L4_aquarius=noutliers_L4_aquarius+sss_qc_aquarius;
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

			ncentral=ndate(ii);
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
			sigma=sqrt(SSS_aquarius_random.^2+sss_erreur_L4.^2);%erreur corrigee

			JJ=[];
			JJ=find(SSS_aquarius>0);
			sss_qc_aquarius(JJ)=0;

			II=[];
			II=find(abs(SSS_aquarius-sss_ref_L4)>3*sigma);

			sss_qc_aquarius(II)=1;

			output_file=([output_dir,'/monthly_',orb,'/aquariusL3_monthlyaveraged_',Datecentral,'centred_',orb])
			save(output_file,'SSS_aquarius','SSS_aquarius_random','SSS_aquarius_bias','nobs_aquarius','sss_qc_aquarius','noutliers_L4_aquarius')
			netcdf.close(nc) 
		end
	end
end
if false
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
title('d. noutliers')
end

