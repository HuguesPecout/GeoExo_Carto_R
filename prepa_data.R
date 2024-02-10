# Import des données géographique
library(sf)
Guinee <- st_read("data/gadm41_GIN_shp/gadm41_GIN_0.shp")
Mali <- st_read("data/gadm41_MLI_shp/gadm41_MLI_0.shp")
Mauritanie <- st_read("data/gadm41_MRT_shp/gadm41_MRT_0.shp")
Guinee_bis <- st_read("data/gadm41_GNB_shp/gadm41_GNB_0.shp")
Gambie <-  st_read("data/gadm41_GMB_shp/gadm41_GMB_0.shp")
Senegal <-  st_read("data/gadm41_SEN_shp/gadm41_SEN_0.shp")

region <- st_read("data/gadm41_SEN_shp/gadm41_SEN_1.shp")
departement <- st_read("data/gadm41_SEN_shp/gadm41_SEN_2.shp")
# region<- ms_simplify(region, 0.1)
# region<- ms_simplify(region, 0.1)
# departement<- ms_simplify(departement, 0.1)
# departement<- ms_simplify(departement, 0.1)

localite <- st_read("data/LA_LOCALITE_P.shp")

all <- rbind(Guinee, Guinee_bis)
all <- rbind(all, Mali)
all <- rbind(all, Mauritanie)
all <- rbind(all, Gambie)
all <- rbind(all, Senegal)

all <- st_transform(all, "EPSG:32628")

# all <- rbind(all, region)

# all <- st_make_valid(all)




library(rmapshaper)
# all<- ms_simplify(all, 0.1)
# all<- ms_simplify(all, 0.1)

Senegal <- st_transform(Senegal, "EPSG:32628")
# Senegal <-  ms_simplify(Senegal, 0.1)
region <- st_transform(region, "EPSG:32628")
departement <- st_transform(departement, "EPSG:32628")

plot(st_geometry(all))
plot(st_geometry(Senegal), add = TRUE)
plot(st_geometry(region), add = TRUE)
plot(st_geometry(departement), add = TRUE)

Pays_voisins <- all
Senegal <- Senegal
Regions <- region
Departements <- departement
Localites <- localite


Regions <- st_cast(Regions, "MULTIPOLYGON")
Departements <- st_cast(Departements, "MULTIPOLYGON")
Pays_voisins <- st_cast(Pays_voisins, "MULTIPOLYGON")



df_pt <- data.frame(NAME = "Université du Sine Saloum El-Hâdj Ibrahima",  y = 14.164166068892895, x = -16.126155055614)
mon_point <- st_as_sf(df_pt, coords = c("x", "y"), crs = 'EPSG:4326')
USSEIN <- st_transform(mon_point, "EPSG:32628")

?st_write
st_write(obj = Pays_voisins, dsn = "data/GeoSenegal.gpkg", layer = "Pays_voisins", delete_layer = T)
st_write(obj = Senegal, dsn = "data/GeoSenegal.gpkg", layer = "Senegal", delete_layer = T)
st_write(obj = Regions, dsn = "data/GeoSenegal.gpkg", layer = "Regions", delete_layer = T)
st_write(obj = Departements, dsn = "data/GeoSenegal.gpkg", layer = "Departements", delete_layer = T)
st_write(obj = Localites, dsn = "data/GeoSenegal.gpkg", layer = "Localites", delete_layer = T)
st_write(obj = USSEIN, dsn = "data/GeoSenegal.gpkg", layer = "USSEIN", delete_layer = T)

st_layers("data/GeoSenegal.gpkg")

#-------------------------------------------------------------------


st_geometry_type(region, by_geometry = TRUE)


plot(st_geometry(world))

# Import des données statistiques
population <- read.csv("data/Population_2015_2024.csv")

# Jointure fond de carte région - données statistique région
data <- merge(region, population, by.x="NOM", by.y="NAME")



# Carte thématique 1 - Cercle proportionnel
library(mapsf)
mf_map(x = data)
mf_map(x = data, 
       var = "P2024",
       type = "prop",
       leg_title = "Population totale"
       )
mf_map(x = senegal), add = T)
mf_title("Distribution de la population par régin, au Sénégal en 204")

