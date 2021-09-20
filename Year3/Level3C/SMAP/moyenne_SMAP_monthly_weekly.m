clear;
close all;

load ('G:\CCI2021\latlon_ease.mat')                             %fichier grille ease
load('G:\CCI2021\mask_smos.mat') %fichier flag lsc
load ('G:\CCI2021\ERR_REP\ERR_REP_1d50km_30d50km_mr2_ctm.mat')  %variabilite hebdomadaire

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
    
    
    input_dir='G:\CCI2021\Smap\Totallycorrected_smap_2\';
    dirL2c=dir(input_dir);
    output_dir='G:\CCI2021\Smap\SSS_SMAP_merged_v3.2\';
    L4_dir=('G:\CCI2021\res3\30days\');
    
    if exist(output_dir)==0; mkdir(output_dir); end
    
    nlon=length(lon_ease);
    nlat=length(lat_ease);
    
    %%%%%%%%%%%%%%%%compute and save 1st week%%%%%%%%%%%%%%%
    
    YYYY0=str2num(dirL2c(4).name(7:10));
    MM0=str2num(dirL2c(4).name(11:12));
    jour0=str2num(dirL2c(4).name(13:14));
    n0=datenum(YYYY0,MM0,jour0);
    
    YYYYend=str2num(dirL2c(end).name(7:10));
    MMend=str2num(dirL2c(end).name(11:12));
    jourend=str2num(dirL2c(end).name(13:14));
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
        ndate=n0:1:nend;     % echantillonne sur 3 jours
        nam1='weekly';
    end
    
    ndate=ndate(find((ndate<=nend-avg)&(ndate>=n0+avg)));
    
    output_dir=[output_dir nam1 '\'];
    if exist(output_dir)==0; mkdir(output_dir); end;
    
    
    for ii=1:length(ndate)% tous les 1er et 15 du mois
        SSScorrigee=nan(avg*8,nlon,nlat);
        randomerror=nan(avg*8,nlon,nlat);
        bias=nan(avg*8,nlon,nlat);
        noutliers_L4_smap=zeros(nlon,nlat);
        Date_kk=datestr(ndate(ii)-avg:ndate(ii)+avg,30);%les dates d un mois
        Date_kk=Date_kk(:,1:8);
        cmpt=0;
        for uu=1:size(Date_kk,1)
            for orb=tabAD
                fic1=[input_dir 'smap' orb '_' Date_kk(uu,:) '.mat'];
                if exist(fic1)~=0
                    
                    load(fic1);
                    %filtrage glace, cote
                    for acq=1:2
                        cmpt=cmpt+1;
                        II=[];
                        II=find((isnan(mask)==1)|(squeeze(totalcorrection(:,:,acq))>20)|(squeeze(WS0(:,:,acq))>16) | squeeze(isc_qc(:,:,acq))==1); %%%mise a jour 05/10/2020 ajout glace year3, on ne met pas sss_qc car ça filtre trop les fleuves
                        SSSinter=SSS_corr(:,:,acq);
                        SSSinter(II)=nan;
                        SSScorrigee(cmpt,:,:)=squeeze(SSSinter);
                        
                        corrinter=totalcorrection(:,:,acq);
                        corrinter(II)=nan;
                        bias(cmpt,:,:)=-squeeze(corrinter);
                        
                        randominter=SSS_random(:,:,acq);
                        randominter(II)=nan;
                        randomerror(cmpt,:,:)=squeeze(randominter);
                        nn=squeeze(sss_qc_smap(:,:,acq));
                        ind=find(nn==1);
                        noutliers_L4_smap(ind)=noutliers_L4_smap(ind)+1;
                    end
                end
            end
        end
        SSScorrigee=SSScorrigee(1:cmpt,:,:);
        bias=bias(1:cmpt,:,:);
        randomerror=randomerror(1:cmpt,:,:);
        
        if (cmpt>0)
            %nobs_total
            nobs_smap=zeros(nlon,nlat);
            for nln=1:nlon
                for nlt=1:nlat
                    UU=find(SSScorrigee(:,nln,nlt)>=0);
                    nobs_smap(nln,nlt)=length(UU);
                end
            end
            %filtre 3 sigma
            
            %keyboard%dbcont%dbquit
            
            SSS_moy=squeeze(tsnanmedian(SSScorrigee));%temps,lon, lat
            SSS_moyenne=nan*ones(size(randomerror));
            
            for kk=1:length(SSS_moyenne(:,1,1))
                SSS_moyenne(kk,:,:,:)=SSS_moy;
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
            
            var_int=tsnansum(1./randomerror.^2,1);
            II=[];
            II=find(var_int==0);
            var_int(II)=nan;
            SSS_smap_random=squeeze(sqrt(1./var_int));
            
            %calcul SSS
            
            var_int=[];
            var_int=tsnansum(SSScorrigee./randomerror.^2,1);
            var_int(II)=nan;
            SSS_smap=squeeze(var_int).*SSS_smap_random.^2;
            
            %calcul biais
            
            %var_int=[];
            var_int=tsnansum(bias./randomerror.^2,1);
            %var_int(II)=nan;
            SSS_smap_bias=squeeze(var_int).*SSS_smap_random.^2;
            
            TT=[];
            TT=find(abs(SSS_smap_bias)>20);% ajoute le 05/10/2020
            SSS_smap_bias(TT)=nan;% ajoute le 05/10/2020
            SSS_smap(TT)=nan;% ajoute le 05/10/2020
            SSS_smap_random(TT)=nan;% ajoute le 05/10/2020
            
            ncentral=ndate(ii);
            Acentral=datestr(ncentral,30);
            Datecentral=Acentral(1:8);
            
            %estimer sss_qc_smap
            
            yyyy=Acentral(1:4);
            mm=Acentral(5:6);
            
            L4_file=([L4_dir yyyy '\ESACCI-SEASURFACESALINITY-L4-SSS-MERGED_OI_Monthly_CENTRED_15Day_25km-',yyyy,mm,'15-fv3.2.nc']);
            nc=netcdf.open(L4_file,'nowrite');
            
            sss_ID=netcdf.inqVarID(nc,'sss');
            sss_ref_L4=double(netcdf.getVar(nc,sss_ID));
            
            ssserror_ID=netcdf.inqVarID(nc,'sss_random_error');
            sss_erreur_L4=double(netcdf.getVar(nc,ssserror_ID));
            
            sss_qc_smap=nan(nlon,nlat);
            hebdo=squeeze(errrepres(:,:,str2num(mm)));
            sigma=sqrt(SSS_smap_random.^2+sss_erreur_L4.^2); %%%corrigee
            
            JJ=[];
            JJ=find(SSS_smap>0);
            sss_qc_smap(JJ)=0;
            
            II=find(abs(SSS_smap-sss_ref_L4)>3*sigma | isnan(sss_ref_L4) | isnan(sigma) | SSS_smap_random>3);
            sss_qc_smap(II)=1;
            
            II=find(isnan(SSS_smap));
            sss_qc_smap(II)=-1;
            noutliers_L4_smap(II)=-1;
            nobs_smap(II)=-1;
            
            if AD==2;
                output_file=([output_dir 'smapL3_averaged_',Datecentral,'_centred_C']);
            elseif AD==1
                output_file=([output_dir 'smapL3_averaged_',Datecentral,'_centred_A']);
            else
                output_file=([output_dir 'smapL3_averaged_',Datecentral,'_centred_D']);
            end
            
            save(output_file,'SSS_smap','SSS_smap_bias','SSS_smap_random','nobs_smap','noutliers_L4_smap','sss_qc_smap')
            netcdf.close(nc)
            
        end
    end
    
    
    load coast
    
    figure(10)
    subplot(2,3,1)
    pcolor(lon_ease,lat_ease,SSS_smap')
    hold on
    plot(long,lat)
    shading flat
    colorbar
    caxis([32 38])
    title('a. SSS')
    
    subplot(2,3,2)
    pcolor(lon_ease,lat_ease,SSS_smap_random')
    shading flat
    hold on
    plot(long,lat)
    colorbar
    caxis([0 0.5])
    title('b. SSS sigma')
    
    II=[];
    II=find(sss_qc_smap==1);
    SSS_smap(II)=nan;
    
    subplot(2,3,3)
    pcolor(lon_ease,lat_ease,SSS_smap')
    hold on
    plot(long,lat)
    shading flat
    colorbar
    caxis([32 38])
    title('c. SSS bias')
    
    subplot(2,3,4)
    pcolor(lon_ease,lat_ease,nobs_smap')
    hold on
    plot(long,lat)
    shading flat
    colorbar
    title('d. SSS count')
    
    subplot(2,3,5)
    pcolor(lon_ease,lat_ease,noutliers_L4_smap')
    hold on
    plot(long,lat)
    shading flat
    colorbar
    title('e. SSS outliers')
    
    subplot(2,3,6)
    pcolor(lon_ease,lat_ease,sss_qc_smap')
    hold on
    plot(long,lat)
    shading flat
    caxis([-2 2])
    colorbar
    title('f. sss QC')
    
end
