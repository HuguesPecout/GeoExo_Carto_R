###################################################################################################
#                                                                                                 #
#                             Cartographie avec R - Exercice appliqué                             #
#                                                                                                 #
###################################################################################################


###################################################################################################
# Chargement des librairies
###################################################################################################

library(sf)
library(mapsf)
library(units)



###################################################################################################
# IMPORT ET JOINTURE
###################################################################################################


# Lister les couches géographiques d'un fichier GeoPackage

# Import des données géographiques
pays <- st_read(dsn = "data/GeoSenegal.gpkg", layer = "Pays_voisins")
sen <-st_read(dsn = "data/GeoSenegal.gpkg", layer = "Senegal")
reg <-st_read(dsn = "data/GeoSenegal.gpkg", layer = "Regions")
dep <-st_read(dsn = "data/GeoSenegal.gpkg", layer = "Departements")
loc <-st_read(dsn = "data/GeoSenegal.gpkg", layer = "Localites")
USSEIN <-st_read(dsn = "data/GeoSenegal.gpkg", layer = "USSEIN")
routes <-st_read(dsn = "data/GeoSenegal.gpkg", layer = "Routes")

# Import des données statistiques
pop <- read.csv("data/Population_2015_2024.csv")

# Jointure entre le fond de carte et les données géographiques
reg <- merge(reg, pop, by.x="NAME_1", by.y="NAME")




###################################################################################################
# 1. CARTE EN SYMBOLES PROPORTIONNELS
###################################################################################################

# Paramètrage de l'export
mf_export(x = sen, filename = "img/carte_1.png", width = 800)
# Initialisation d'un thème
mf_theme(bg = "steelblue3", fg= "grey10")
# Centrage de la carte sur le Sénégal
mf_map(x = reg, col = NA, border = NA)
# Ajout des limites des pays voisins
mf_map(pays, add = TRUE)
# Ajout d'un effet d'ombrage sur le Sénégal
mf_shadow(sen, add = TRUE)
mf_map(reg, col = "grey95", add=T)

# Ajout d'un carton de localisation de type "worldmap"
mf_inset_on(x = "worldmap",cex = .16, pos = "topright")
# Localisation du Sénégal sur la planisphère
mf_worldmap(sen)
mf_inset_off()

# Construction de symboles proportionnels pour la population en 2024 par région
mf_map(x = reg, 
       var = "P2024",
       type = "prop",
       col = "indianred3",
       inches = 0.3,
       leg_pos = c(806488.1, 1730211),
       leg_frame = TRUE,
       leg_title_cex = 0.7,
       leg_val_cex = 0.5,
       leg_bg = "#FFFFFF99",
       leg_title = "Nombre d'habitants")

# Ajout d'une annotation (localisation de USSEIN)
mf_annotation(x = USSEIN, 
              txt = "USSEIN", 
              halo = TRUE, 
              bg = "grey85",
              cex = 0.65)

# Titre
mf_title("Répartition de la population au Sénégal, par régions en 2024", fg = "white")
# Sources
mf_credits("Auteurs : Hugues Pecout\nSources : GADM & ANSD (2024)", cex = 0.5)

# Enregistrement du fichier png
dev.off()




###################################################################################################
# 2. CARTE CHOROPLHETE
###################################################################################################

#### CALCUL DENSITE
# Calcul de la surface de chaque régions dans l'unité de la projection (m2)
reg$surface <- st_area(reg)
reg$surface

# Conversion de la surface en km2
reg$surface <- set_units(x= reg$surface, value = km^2)

# Calcul de la densité de population par km2 en 2024
reg$dens_pop24 <- reg$P2024/reg$surface



#### CHOIX DISCRETISATION
# Justification de la discrétisation (statistiques, boxplot, histogramme, beeswarm...) ?

# Histogramme
hist(reg$dens_pop24, breaks = 30)
hist(log(reg$dens_pop24))

# Supression de l'unité associée aux valeur du vecteur
reg$dens_pop24 <-as.vector(reg$dens_pop24)
# Choix des bornes de classe pour la discrétisation
bornes <- c(min(reg$dens_pop24), 45, 100, 200, 500, max(reg$dens_pop24))

# Représentation graphique de la discrétisation choisie
hist(log(reg$dens_pop24), breaks =20)
abline(v=log(bornes), col = "red", lwd = 2)



#### CARTE
# Paramètrage de l'export
mf_export(x = sen, filename = "img/carte_2.png", width = 800)
# Initialisation d'un thème
mf_theme(bg = "steelblue3", fg= "grey10")
# Centrage de la carte sur le Sénégal
mf_map(x = sen, col = NA, border = NA)
# Ajout des limites des pays voisin
mf_map(pays, add = TRUE)
# Ajout d'un effet d'ombrage sur le Sénégal
mf_shadow(sen, add = TRUE)

# Carte choroplèthe sur la densité de population par régions
mf_map(x = reg, 
       var = "dens_pop24",
       type = "choro",
       breaks = bornes,
       pal = "Peach",
       leg_title = "Habitants par km2",
       add = TRUE)

# Ajout d'étiquettes avec les noms des régions
mf_label(x = reg,
         var = "NAME_1",
         col= "black",
         halo = TRUE,
         bg = "grey85",
         cex = 0.7,
         overlap = FALSE, 
         lines = FALSE)

# Ajout d'un toponyme ("Océan Atlantique")
text(x = 261744.7, y = 1766915, labels = "Océan\nAtlantique", col="#FFFFFF99", cex = 0.65)

# Titre
mf_title("Densité de population au Sénégal, par régions en 2024", fg = "white")
# Sources
mf_credits("Auteurs : Hugues Pecout\nSources : GADM & ANSD (2024)", cex = 0.5)

# Enregistrement du fichier png
dev.off()





###################################################################################################
# 3. CARTE COMBINEE - Stock et ratio
###################################################################################################

#### TAUX D'EVOLUTION 
# Calcul du taux d'évolution de la population entre 2015 et 2024
reg$evo_pop_15_24 <- (reg$P2024 - reg$P2015) / reg$P2015 *100


#### DISCRETISATION
# Histogramme - Quelle discrétisation choisir ?
hist(reg$evo_pop_15_24)

# Choix des bornes de classe pour la discrétisation
bornes <- mf_get_breaks(reg$evo_pop_15_24, breaks = "quantile")
  

#### CARTE 
# Paramètrage de l'export
mf_export(x = sen, filename = "img/carte_3.png", width = 800)
# Initialisation d'un thème
mf_theme(bg = "steelblue3", fg= "grey10")
# Centrage de la carte sur le Sénégal
mf_map(x = reg, col = NA, border = NA)
# Ajout des limites des pays voisin
mf_map(pays, add = TRUE)
# Ajout d'un effet d'ombrage sur le Sénégal
mf_shadow(sen, add = TRUE)
mf_map(reg, col = "grey95", add=T)

# Carte en symboles proportionnels (P2024) + carte choroplèthe (Taux d'évolution de la pop)
mf_map(x = reg, 
       var = c("P2024", "evo_pop_15_24"),
       type = "prop_choro",
       border = "grey50",
       lwd = 1,
       inches = 0.3,
       leg_title = c("Nombre d'habitants\nen 2024", "Taux d'évolution (%)\nentre 2015 et 2024"),
       leg_title_cex = 0.7,
       leg_val_cex = 0.5,
       leg_frame = TRUE,
       leg_bg = "#FFFFFF99",
       breaks = bornes,
       pal = "Magenta",
       leg_val_rnd = c(0,1))

# Ajout d'une annotation (localisation de USSEIN)
mf_annotation(x = USSEIN, txt = "USSEIN", halo = TRUE, bg = "grey85", cex = 1.1)

# Ajout de toponymes
text(x = 261744.7, y = 1766915, labels = "Océan\nAtlantique", col="#FFFFFF99", cex = 0.65)
text(x = 456008.1, y = 1490739, labels = "Gambie", col="#00000099", cex = 0.6)
text(x = 496293.2, y = 1364960, labels = "Guinée-Bissau", col="#00000099", cex = 0.6)
text(x = 748298.6, y = 1355112, labels = "Guinée", col="#00000099", cex = 0.6)
text(x = 875867.9, y = 1541766, labels = "Mali", col="#00000099", cex = 0.6)
text(x = 683394.9, y = 1818838, labels = "Mauritanie", col="#00000099", cex = 0.6)

# Titre
mf_title("Évolution de la population au Sénégal, 2015-2024", fg = "white")
# Sources
mf_credits("Auteurs : Hugues Pecout\nSources : GADM & ANSD (2024)", cex = 0.5)

# Enregistrement du fichier png
dev.off()



