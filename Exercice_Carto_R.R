# Import des données géographique
library(sf)
departement <- st_read("data/LA_DEPARTEMENT_S.shp")
region <- st_read("data/LA_REGION_S.shp")
senegal <- st_read("data/LA_FRONTIERE_INTERNATIONALE_FRONTIERE_ETAT_L.shp")


world <- st_read("data/gadm_410.gpkg")

st_layers("data/gadm_410.gpkg")

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

