
require(gdistance)

travel_file = "travel-lines/actual-fric/road-act.tif"
dest_file = "hospital-dist/hospitals_xy.csv"
out_file = "hospital-dist/road_hospital.tif"

r = raster(travel_file)

left   <- xmin(r)
right  <- xmax(r)
bottom <- ymin(r)
top    <- ymax(r)

transition.matrix.exists.flag <- 0 

# Input Files:
 # 1) friction surface 
 # 2) destination points as csv 
friction.surface.filename <- travel_file
point.filename <- dest_file

# Output Files
T.filename <- 'study.area.T.rds'
T.GC.filename <- 'study.area.T.GC.rds'
output.filename <- out_file

# destination points 
points <- read.csv(file = point.filename)

temp <- dim(points)
n.points <- temp[1]
friction <- raster(friction.surface.filename)
fs1 <- crop(friction, extent(left, right, bottom, top))

if (transition.matrix.exists.flag == 1) {
  T.GC <- readRDS(T.GC.filename)
} else {
  # construct graph representation
  T <- transition(fs1, function(x) 1/mean(x), 8) 
  saveRDS(T, T.filename)
  T.GC <- geoCorrection(T)
  saveRDS(T.GC, T.GC.filename)
}

xy.data.frame <- data.frame()
xy.data.frame[1:n.points,1] <- points[,1]
xy.data.frame[1:n.points,2] <- points[,2]
xy.matrix <- as.matrix(xy.data.frame)

temp.raster <- accCost(T.GC, xy.matrix)
writeRaster(temp.raster, output.filename, overwrite=TRUE)
