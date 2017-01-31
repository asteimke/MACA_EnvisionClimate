# MACA_EnvisionClimate

Takes gridded MACA downscaled climate files (in .nc) and formats them to be readable for the Envision model

MACA --> http://maca.northwestknowledge.net/index.php

Envision --> http://envision.bioe.orst.edu/Default.aspx


1) download MACA data for following variables (huss pr rsds tasmax tasmin uas vas) for any climate models / scenarios
2) specify scenarios, climate models, and study area naming convention in both .sh files
3) run processing.sh
4) change # of years for future/historical simulations in subsetYears.sh
5) run subsetYears.sh
