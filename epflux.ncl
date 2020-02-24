;----------------------------------------------------------------------
; Script for plotting Eliassen-Palm Flux as generated by OpenIFS
;
;=======================================================================
;                  MAIN: 6.4.0 or later
;=======================================================================
;
; file names; open each; size information  

  minlat	= 80
  maxlat	= 159
  show_accel 	= 0
  pltDir	= "/p/project/chhb19/jstreffi/postprocessing/PAMIP/"              ; dir for output plot
  pltType    	= "png"             ; getenv("pltType")   
  pltRoot    	= "epflux"          ; getenv("pltRoot")

  res	= getenv("res")		; model resolution
  exp1	= getenv("exp1")	; experiment id 1
  exp2	= getenv("exp2")	; experiment id 2
 
  epf1	= addfile("./T"+tostring(res)+"/Experiment_"+tostring(exp1)+"/epflux/epf_"+tostring(exp1)+"_ensmean.nc", "r")    ; file references (pointers)
  epf2	= addfile("./T"+tostring(res)+"/Experiment_"+tostring(exp2)+"/epflux/epf_"+tostring(exp2)+"_ensmean.nc", "r")    ; file references (pointers)
  print(epf1)

  Fphi1	= epf1->Fphi(:,:,:) 
  Fphi2	= epf2->Fphi(:,:,:) 
  Fp1	= epf1->Fp(:,:,:)
  Fp2	= epf2->Fp(:,:,:)
  EPdiv1= epf1->EPdiv(:,:,:)
  EPdiv2= epf2->EPdiv(:,:,:)
  dudt1 = epf1->dudt(:,:,:)
  dudt2 = epf1->dudt(:,:,:)

  plev	= epf1->plev(:)/100
  time	= epf1->time(:)
  lat   = epf1->lat(:)

  monthname = (/"January","February","March","April" \
               ,"May","June","July","August" \
               ,"September","October","November","December" /)

i = 0
do while (i.le.11)  

  vectitle =   "EPFlux monthly average for "+monthname(i) 
  print("Plotting "+vectitle)

  ;************************************************
  ; Create Plot 
  ;************************************************
  ; create vector plot resources for pressure-level grid 
  ;************************************************
    res_vec = True
    res_vec@gsnMaximize           = True              ; make ps/eps/pdf large (no effect otherwise)
    res_vec@gsnDraw               = False             ; allows for manual overlaying        
    res_vec@gsnFrame              = False        

    res_vec@vfXArray              = lat(minlat:maxlat)               ; use lat for x axis
    res_vec@vfYArray              = plev              ; use pressure for y axis
    res_vec@trYReverse            = True              ; reverse y-axis
    res_vec@gsnYAxisIrregular2Log = True              ; set y-axis to log scale

    res_vec@tiXAxisString         = "latitude"        ; x-axis label
    res_vec@tiYAxisString         = "pressure (mb)"   ; y-axis label
    res_vec@tiXAxisFontHeightF    = 0.0175
    res_vec@tiYAxisFontHeightF    = 0.0175

    res_vec@vcRefMagnitudeF       = 50               ; add a reference vector
    res_vec@vcRefLengthF          = 0.05              ; what the ref length is
    res_vec@vcMonoLineArrowColor  = False             ; vec's colored by their mag
    res_vec@vcLevelPalette        = "rainbow"         
    res_vec@vcLevelSelectionMode  = "ManualLevels"
    res_vec@vcLevelSpacingF       = 5.0
    res_vec@vcMinLevelValF        = 0.0
    res_vec@vcMaxLevelValF        = 100
    res_vec@vcRefAnnoOn           = False              ; turn off ref wind barb
    res_vec@vcMinDistanceF        = 0.00875            ; trial and error

    res_vec@pmLabelBarDisplayMode = "Always"          ; Turn on a label bar.
    res_vec@pmLabelBarWidthF      = 0.08              ; make it thinner
    res_vec@lbPerimOn             = False             ; no box around it

    res_vec@tiMainString          = vectitle          ; plot title
    res_vec@tiMainFontHeightF     = 0.0185

    res_vec@tmXBLabelFontHeightF  = 0.0125
    res_vec@tmYLLabelFontHeightF  = 0.0125
    res_vec@tmXBMajorLengthF      = -0.0075           ; minus mean outward face
    res_vec@tmYLMajorLengthF      = -0.0075           ; minus mean outward face

    res_vec@tmYLMode              = "Explicit"        ; Pressure (YL) axis
    res_vec@tmYLValues            = plev            
    res_vec@tmYLLabels            = tostring(toint(plev)) 
;    res_vec@tmYLLabels(1)         = ""                ; no 925 label
;    res_vec@tmYLLabels(2)         = ""                ;    850
;    res_vec@tmYLLabels(4)         = ""                ;    600
;    res_vec@tmYLLabels(8)         = ""                ;    250
  
    res_vec@vpWidthF              = 0.60              ; shape
    res_vec@vpHeightF             = 0.35

; Create contour plot resources

    res_con                       = True
    res_con@gsnDraw               = False
    res_con@gsnFrame              = False

    res_con@sfXArray              = res_vec@vfXArray   ; =lat(minlat:maxlat)
    res_con@sfYArray              = res_vec@vfYArray   ; =plev
    res_con@trYReverse            = True               ; reverse y-axis

    res_con@gsnYAxisIrregular2Log = True               ; set y-axis to log scale
    res_con@gsnContourZeroLineThicknessF = 0.0
    res_con@gsnContourPosLineDashPattern = 2
   ;res_con@gsnContourNegLineDashPattern = 2

    res_con@cnSmoothingOn         = True
    res_con@cnLineColor           = "black"      
    res_con@cnLineThicknessF      = 2.0                ; default is 1.0
   ;res_con@gsnContourLineThicknessesScale  = 0.5
    res_con@cnLineLabelsOn        = False
   ;res_con@cnInfoLabelOn         = False              ; default is True
  


; Experiment1: open file and create graphic

  pltType = "png"
  pltPath = pltDir+pltRoot+"_"+monthname(i)+"_Experiment_"+exp1
  wks     = gsn_open_wks(pltType,pltPath)                
  plotvec = gsn_vector(wks,Fphi1(i,:,minlat:maxlat),Fp1(i,:,minlat:maxlat),res_vec)    

  if (show_accel .eq. 1) then 
      dudt1@_FillValue = -999.0
      dudt1(i,0,:) = dudt1@_FillValue                  ; Hide the 1000 mb level
      res_con@cnLevelSpacingF        = 5.          ; Contour level Spacing
      plotvec2 = gsn_contour(wks,dudt1(i,:,minlat:maxlat),res_con)     ; Creates plot for du/dt = div(F)/(a*cos(phi))
      overlay(plotvec,plotvec2)
  else
      EPdiv1@_FillValue = -999.0
      EPdiv1(i,0,:) = EPdiv1@_FillValue                ; Hide the 1000 mb level
      res_con@cnLevelSpacingF        = 200.        ; Contour level Spacing
      plotvec3 = gsn_contour(wks,EPdiv1(i,:,minlat:maxlat),res_con)    ; Creates plot for div(F)
      overlay(plotvec,plotvec3)
  end if

  draw(plotvec)
  frame(wks)




; Experiment2: open file and create graphic

  pltType = "png"
  pltPath = pltDir+pltRoot+"_"+monthname(i)+"_Experiment_"+exp2
  wks     = gsn_open_wks(pltType,pltPath)                
  plotvec = gsn_vector(wks,Fphi2(i,:,minlat:maxlat),Fp2(i,:,minlat:maxlat),res_vec)    

  if (show_accel .eq. 1) then 
      dudt2@_FillValue = -999.0
      dudt2(i,0,:) = dudt1@_FillValue                  ; Hide the 1000 mb level
      res_con@cnLevelSpacingF        = 5.          ; Contour level Spacing
      plotvec2 = gsn_contour(wks,dudt2(i,:,minlat:maxlat),res_con)     ; Creates plot for du/dt = div(F)/(a*cos(phi))
      overlay(plotvec,plotvec2)
  else
      EPdiv2@_FillValue = -999.0
      EPdiv2(i,0,:) = EPdiv2@_FillValue                ; Hide the 1000 mb level
      res_con@cnLevelSpacingF        = 200.        ; Contour level Spacing
      plotvec3 = gsn_contour(wks,EPdiv2(i,:,minlat:maxlat),res_con)    ; Creates plot for div(F)
      overlay(plotvec,plotvec3)
  end if

  draw(plotvec)
  frame(wks)

; Experiment2-Experiment1: open file and create graphic



    res_vec@vcRefMagnitudeF       = 50               ; add a reference vector
    res_vec@vcRefLengthF          = 0.05              ; what the ref length is
    res_vec@vcLevelSpacingF       = 5
    res_vec@vcMaxLevelValF        = 100


  pltType = "png"
  pltPath = pltDir+pltRoot+"_diff_"+monthname(i)+"_Experiment_"+exp2+"-"+exp1
  wks     = gsn_open_wks(pltType,pltPath)
  plotvec = gsn_vector(wks,Fphi2(i,:,minlat:maxlat)-Fphi1(i,:,minlat:maxlat),Fp2(i,:,minlat:maxlat)-Fp1(i,:,minlat:maxlat),res_vec)

  if (show_accel .eq. 1) then
      dudt1@_FillValue = -999.0
      dudt1(i,0,:) = dudt1@_FillValue                  ; Hide the 1000 mb level
      res_con@cnLevelSpacingF        = 5.          ; Contour level Spacing
      plotvec2 = gsn_contour(wks,dudt2(i,:,minlat:maxlat)-dudt1(i,:,minlat:maxlat),res_con)     ; Creates plot for du/dt = div(F)/(a*cos(phi))
      overlay(plotvec,plotvec2)
  else
      EPdiv2@_FillValue = -999.0
      EPdiv2(i,0,:) = EPdiv2@_FillValue                ; Hide the 1000 mb level
      res_con@cnLevelSpacingF        = 200.        ; Contour level Spacing
      plotvec3 = gsn_contour(wks,EPdiv2(i,:,minlat:maxlat)-EPdiv1(i,:,minlat:maxlat),res_con)    ; Creates plot for div(F)
      overlay(plotvec,plotvec3)
  end if

  draw(plotvec)
  frame(wks)


  i=i+1
end do

  print ( "done" )
