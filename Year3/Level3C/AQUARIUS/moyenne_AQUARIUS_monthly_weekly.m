% mise a jour year3

clear
close all;


load ('G:\CCI2021\latlon_ease.mat')                             %fichier grille ease
load('G:\CCI2021\mask_smos.mat') %fichier flag lsc
load ('G:\CCI2021\ERR_REP\ERR_REP_1d150km_30d50km_mr2_ctm.mat')  %variabilite hebdomadaire

window0='hebd'  % mens ou hebd

for AD=1:3;           % 2 pour A+D; 1 pour A; 0 pour D
    
    if AD==2
        tabAD=['A' 'D']
        fAB=2;
    elseif AD==1
        tabAD=['A']
        fAB=1;
    else
        tabAD=['D']
        fAB=1;
    end
    
    input_dir=('G:\CCI2021\Aquarius\Totallycorrected_aquarius_2\');
    dirL2c=dir(input_dir);
    output_dir='G:\CCI2021\Aquarius\SSS_AQUARIUS_merged_3.2\';
    L4_dir=('G:\CCI2021\res3\30days\');
    
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
    
    %creer liste de dates 1er et 15 de chaque mois
    if strcmp(window0,'mens')
        avg=15;   % demi-largeur de la fenetre
        cmpt1=1;
        cmpt15=2;
        for yy=1:YYYYend-YYYY0+1
            for MM=1:12
                YY=yy+YYYY0-1;
                ndate(cmpt1)=datenum(YY,MM,1);  % echantillonne sur 15 jours
                ndate(cmpt15)=datenum(YY,MM,15);
                cmpt1=cmpt1+2;
                cmpt15=cmpt15+2;
            end
        end
        nam1='monthly';
    elseif strcmp(window0,'hebd')
        avg=3;
        ndate=n0:1:nend;     % echantillonne sur 1 jour
        nam1='weekly';
    end
    
    ndate=ndate(find((ndate<=nend-avg)&(ndate>=n0+avg)));
    
    output_dir=[output_dir nam1 '\'];
    if exist(output_dir)==0; mkdir(output_dir); end;
    
    for ii=1:length(ndate)%tous les mois possibles entre t0 et tend
        SSS_corr=nan(avg*4*fAB,nlon,nlat);%avg*2 !!!!!!!!
        eSSS0=nan(avg*4*fAB,nlon,nlat);
        totalcorrection=nan(avg*4*fAB,nlon,nlat);
        noutliers_L4_aquarius=zeros(nlon,nlat);
        Date_kk=datestr(ndate(ii)-avg:ndate(ii)+avg,30);%les dates d un mois
        cmpt=0;
        for uu=1:size(Date_kk,1)
            for orb=tabAD
                list=dir([input_dir,'aquariusL3corrected_' Date_kk(uu,1:8) '_' orb '.mat']);
                if (length(list)>0)
                    for ff=1:length(list)
                        input_file=([input_dir,list(ff).name]);
                        load(input_file);
                        cmpt=cmpt+1;
                        
                        %filtrage glace, cote
                        II=find( isnan(mask)==1 | totalcorrection>20 | isc_qc==1);
                        
                        SSS_corr(II)=nan;
                        totalcorrection(II)=nan;
                        SSS_random(II)=nan;
                        
                        Bias(cmpt,:,:)=-totalcorrection;
                        SSScorrigee(cmpt,:,:)=SSS_corr;
                        randomerror(cmpt,:,:)=SSS_random;
                        
                        ind=find(sss_qc_aquarius==1);
                        noutliers_L4_aquarius(ind)=noutliers_L4_aquarius(ind)+1;
                    end
                end
            end
        end
        cmpt
        if (cmpt>0)
            %filtre 3 sigma
            
            %keyboard%dbcont%dbquit
            
            SSS_moy=squeeze(tsnanmedian(SSScorrigee));%temps,lon, lat
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
            
            var_int=tsnansum(1./randomerror.^2,1);
            II=[];
            II=find(var_int==0);
            var_int(II)=nan;
            SSS_aquarius_random=squeeze(sqrt(1./var_int));
            
            %calcul SSS
            
            var_int=[];
            var_int=tsnansum(SSScorrigee./randomerror.^2,1);
            var_int(II)=nan;
            SSS_aquarius=squeeze(var_int).*SSS_aquarius_random.^2;
            
            %calcul biais SSS
            
            var_int=[];
            var_int=tsnansum(Bias./randomerror.^2,1);
            var_int(II)=nan;
            SSS_aquarius_bias=squeeze(var_int).*SSS_aquarius_random.^2;
            
            TT=[];
            TT=find(abs(SSS_aquarius_bias)>20);% ajoute le 05/10/2020
            SSS_aquarius_bias(TT)=nan;% ajoute le 05/10/2020
            SSS_aquarius(TT)=nan;% ajoute le 05/10/2020
            SSS_aquarius_random(TT)=nan;% ajoute le 05/10/2020
            
            ncentral=ndate(ii);
            Acentral=datestr(ncentral,30);
            Datecentral=Acentral(1:8);
            
            %estimer sss_qc_aquarius
            
            yyyy=Acentral(1:4);
            mm=Acentral(5:6);
            
            L4_file=([L4_dir yyyy '\ESACCI-SEASURFACESALINITY-L4-SSS-MERGED_OI_Monthly_CENTRED_15Day_25km-',yyyy,mm,'15-fv3.2.nc']);
            nc=netcdf.open(L4_file,'nowrite');
            
            sss_ID=netcdf.inqVarID(nc,'sss');
            sss_ref_L4=double(netcdf.getVar(nc,sss_ID));
            
            ssserror_ID=netcdf.inqVarID(nc,'sss_random_error');
            sss_erreur_L4=double(netcdf.getVar(nc,ssserror_ID));
            
            sss_qc_aquarius=nan(nlon,nlat);
            hebdo=squeeze(errrepres(:,:,str2num(mm)));
            sigma=sqrt(SSS_aquarius_random.^2+sss_erreur_L4.^2);%%erreur corrigee
            
            JJ=find(SSS_aquarius>0);
            sss_qc_aquarius(JJ)=0;
            
            II=find(abs(SSS_aquarius-sss_ref_L4)>3*sigma | isnan(sss_ref_L4) | isnan(sigma) | SSS_aquarius_random>3);
            sss_qc_aquarius(II)=1;
            
                        
            II=find(isnan(SSS_aquarius));
            sss_qc_aquarius(II)=-1;
            noutliers_L4_aquarius(II)=-1;
            nobs_aquarius(II)=-1;
            SSS_aquarius_random(II)=NaN;
            SSS_aquarius_bias(II)=NaN;
            
            if AD==2;
                output_file=([output_dir 'aquariusL3_averaged_',Datecentral,'_centred_C']);
            elseif AD==1
                output_file=([output_dir 'aquariusL3_averaged_',Datecentral,'_centred_A']);
            else
                output_file=([output_dir 'aquariusL3_averaged_',Datecentral,'_centred_D']);
            end
            
            save(output_file,'SSS_aquarius','SSS_aquarius_random','SSS_aquarius_bias','nobs_aquarius','sss_qc_aquarius','noutliers_L4_aquarius')
            netcdf.close(nc)
            
            
        end
    end
    
    load G:\CCI2021\coast
    
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
  
    subplot(2,2,3)
    pcolor(lon_ease,lat_ease,sss_qc_aquarius')
    hold on
    plot(long,lat)
    shading flat
    colorbar
    caxis([-2 2])
    title('c. SSS QC')
    
    subplot(2,2,4)
    pcolor(lon_ease,lat_ease,noutliers_L4_aquarius')
    shading flat
    caxis([-2 5])
    colorbar
    hold on
    plot(long,lat)
    colorbar
    title('d. noutliers')
    
end

