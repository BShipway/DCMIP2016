;***********************************************
; plot_supercell_init.ncl
;***********************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"  

;************************************************
begin

;************************************************
; Input parameters
;************************************************

  datafilename = "../../../tempestmodel/test/dcmip2016/outSupercellTest/out.0000-01-01-00000.nc"

;************************************************
; Initialize workspace
;************************************************

  wks = gsn_open_wks("eps","plot_supercell_init_p2")   

;************************************************
; Plot resources [options]
;************************************************

  res                     = True
 ;res@mpCenterLonF        = 180
  res@cnFillOn            = True       ; color              [default=False]
  res@cnLinesOn           = True       ; draw contour lines [default=True]
  res@lbLabelAutoStride   = True
  res@vpKeepAspect        = True
  res@vpWidthF            = 0.38       ; user specified shape
  res@vpHeightF           = 0.19
  res@gsnSpreadColors     = True       ; use all colors
  res@gsnSpreadColorStart = 2          ; default=2
  res@gsnSpreadColorEnd   = 23        ; final color of "gui-default"
;  res@gsnSpreadColorStart = 2          ; default=2
;  res@gsnSpreadColorEnd   = 11        ; final color of "cosam"

  res@gsnDraw             = False      ; default=True
  res@gsnFrame            = False      ; default=True

  res@trYMaxF = 20.0

  res_u                   = res        ; zonal velocity plot resources
  res_t                   = res        ; temperature plot resources
  res_td                  = res        ; temperature diff plot resources
  res_thetap              = res        ; theta perturbation plot resources

;************************************************
; Panel plot
;************************************************
  plot = new(4,graphic)
  gsn_merge_colormaps(wks,"gui_default", "BlWhRe")
;  gsn_merge_colormaps(wks,"cosam", "BlRe")

  datafile = addfile(datafilename, "r")

  lev = datafile->lev

  rho = datafile->Rho
  t = datafile->T
  theta = datafile->Theta
  u = datafile->U

  qv = datafile->RhoQv / rho * 1000.0
  copy_VarCoords(rho, qv)
 
  t = t / (1.0 + 0.61 * qv / 1000.0)
  copy_VarCoords(rho, t)

  p = rho * 287.0 * t / 100.0
  copy_VarCoords(rho, p)

  ps = (p(0,0,:,:) * lev(1) - p(0,1,:,:) * lev(0)) / (lev(1) - lev(0))
  copy_VarCoords(rho(0,0,:,:), ps)

  nlat = dimsizes(theta(0,0,:,0))
  ilateq = nlat/2

  td = t
  do i=0,nlat-1
    td(0,:,i,:) = t(0,:,i,:) - t(0,:,ilateq,:)
  end do
  copy_VarCoords(t, td)

  thetap = theta(0,:,:,180) - theta(0,:,:,0)
  copy_VarCoords(theta(0,:,:,0), thetap)

; ---
  z = lev * 20.0
  p&lev = z
  t&lev = z
  td&lev = z
  theta&lev = z
  qv&lev = z
  u&lev = z
  thetap&lev = z

; ---

  res_t@cnLevelSelectionMode= "ManualLevels"
  res_t@cnLevelSpacingF   = 10.0
  res_t@cnMinLevelValF    = 200.0
  res_t@cnMaxLevelValF    = 310.0

  res_t@tiYAxisString     = "Altitude (km)"
  res_t@gsnCenterString   = "Temperature (T)"
  res_t@gsnRightString    = "(K)"
  plot(0) = gsn_csm_contour(wks,t(0,:,:,0),res_t)

  res_td@cnLevelSelectionMode= "ManualLevels"
  res_td@cnLevelSpacingF   = 0.2
  res_td@cnMinLevelValF    = -2.0
  res_td@cnMaxLevelValF    = 2.0

  res_td@trXMinF = 0.
  res_td@trXMaxF = 90.

  res_td@gsnSpreadColorStart = 24
  res_td@gsnSpreadColorEnd = 150

  res_td@tiYAxisString     = "Altitude (km)"
  res_td@gsnCenterString   = "T - T~B~eq~E~"
  res_td@gsnRightString    = "(K)"
  plot(1) = gsn_csm_contour(wks,td(0,:,:,0),res_td)

; ---

  res_thetap@cnLevelSelectionMode= "ManualLevels"
  res_thetap@cnLevelSpacingF   = 0.2
  res_thetap@cnMinLevelValF    = 0.2
  res_thetap@cnMaxLevelValF    = 3.0

  res_thetap@gsnSpreadColorStart = 75
  res_thetap@gsnSpreadColorEnd = 150

  res_thetap@tiYAxisString     = "Altitude (km)"
  res_thetap@gsnCenterString   = "Theta perturbation"
  res_thetap@gsnRightString    = "(K)"
  plot(2) = gsn_csm_contour(wks,thetap(:,:),res_thetap)

; ---

  pres = True
  pres@gsnFrame = False
  pres@gsnPanelYWhiteSpacePercent = 5
  pres@gsnPanelBottom = 0.1

  gsn_panel(wks,plot,(/2,2/),pres)

  frame(wks)


end
