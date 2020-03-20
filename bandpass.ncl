;----------------------------------------------------------------------
; bandpass.ncl
;
; Calculates 2-8 day Lanczos bandpass filter 
;=======================================================================
;                  MAIN: 6.4.0 or later
;=======================================================================

;---Set options
  dir     = "./"                      					; directory with file
  var     = getenv("var")             					; model resolution
  fi      = addfile(dir+var+"_bpf_prep", "r")    			; file references (pointers)
  fo      = dir+var+"_bpf.nc"    				                ; file references (pointers)


; import the desired variables for the specified time period		; (time,plev,lat,lon)
  data   = short2flt(fi->$var$(:,:,:,:))  


; construction Lanczos filter
  fca    = 0.25/8                     					; low frequency cutoff
  fcb    = 0.25/2                     					; high frequency cutoff
  nwt    = 31			      					; number of points for filter
  ihp    = 2			      					; 0=highpass 1=lowpass 2=bandpas
  nsigma = 1.			      					; power of the sigma factor
  wgt    = filwgts_lanczos (nwt, ihp, fca, fcb, nsigma)  


; compute running avarage
  print(dimsizes(data))
  filtered = wgt_runave (data(plev|:,lat|:,lon|:,time|:), wgt, 0)   	; compute running ave

; return variable to original dimension  order
  filtered!0 = "plev"							; giving names for later reorder
  filtered!1 = "lat"
  filtered!2 = "lon"
  filtered!3 = "time"
  out = filtered(time|:,plev|:,lat|:,lon|:)				; reorder

  ncdf = addfile(fo ,"c")  						; open output netCDF file
  filedimdef(ncdf,"time",-1,True) 					; make a time axis
  ncdf->$var$  = out                        				; write output into file

