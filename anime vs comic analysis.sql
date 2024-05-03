USE Anime_data;

# Visionado de películas por ubicación geográfica: (JOIN + GROUP BY #1)

SELECT
    d.Location AS Country,
    COUNT(*) AS View_Count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Percentage
FROM
    user_score_2023 u
JOIN
    user_details_2023 d ON u.user_id = d.Mal_ID
GROUP BY
    d.Location
ORDER BY
	Percentage DESC;

    
# Visionado de películas por usuario (JOIN + GROUP BY #2)

SELECT
    u.username AS User_ID,
    COUNT(*) AS View_Count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Percentage
FROM
    user_score_2023 u
JOIN
    user_details_2023 d ON u.user_id = d.Mal_ID
GROUP BY
    u.username
ORDER BY
	Percentage DESC;
    
# Mayor número de episodios vistos por país: (JOIN + GROUP BY #3)

SELECT
    d.Location AS Location,
    SUM(d.Episodes_Watched) AS Total_Episodes_Watched
FROM
    user_details_2023 d
JOIN
    user_score_2023 u ON d.Mal_ID = u.user_id
GROUP BY
    d.Location
ORDER BY
	Total_Episodes_Watched DESC;
    
# ¿Cual es el título que más gusta por usuario?: (JOIN #1 + SUBQUERY)

SELECT
    d.Username AS Username,
    a.Name AS Favorite_Anime,
    u.rating AS Max_Rating
FROM
    user_details_2023 d
JOIN
    user_score_2023 u ON d.Mal_ID = u.user_id
JOIN
    anime_filtered a ON u.anime_id = a.anime_id
WHERE
    (u.rating, d.Username) IN (
        SELECT MAX(u.rating), d.Username
        FROM user_score_2023 u
        JOIN user_details_2023 d ON u.user_id = d.Mal_ID
        GROUP BY d.Username
    );


# ¿Cual es la película que más gusta a los usuarios Top 5 por episodios vistos: Hopis, Phony2, Crystal, Ticat, Chazist? (JOIN + GROUP BY #4)

SELECT
    d.Username AS Username,
    a.Name AS Favorite_Anime
FROM
    user_details_2023 d
JOIN
    user_score_2023 u ON d.Mal_ID = u.user_id
JOIN
    anime_filtered a ON u.anime_id = a.anime_id
WHERE
    d.Username IN ('Hopis', 'Phony2', 'Crystal', 'Ticat', 'Chazist')
GROUP BY
    d.Username,
    a.Name
ORDER BY
    a.Name ;

# Cantidad de usuarios el día de la Premier (GROUP BY #1)

SELECT
    Premiered,
    COUNT(*) AS Total_times
FROM
    anime_filtered
GROUP BY
    Premiered
ORDER BY
    Total_times DESC;
    
# Top 5 de la popularidad de un anime según su puntuación de la columna POPULARITY: (CASE #1)

SELECT
    Name,
    Popularity
FROM (
    SELECT
        Name,
        Popularity,
        CASE
            WHEN Popularity > 5000 THEN 'Popular'
            ELSE 'No Popular'
        END AS Popularidad_Evaluada
    FROM
        anime_filtered
) AS Animes_Clasificados
WHERE
    Popularidad_Evaluada = 'Popular'
ORDER BY
    Popularity DESC
LIMIT 5;

# Top 5 y Down 5 de la popularidad de un anime según su puntuación de la columna POPULARITY: (UNION #1)

(
    SELECT
        Name,
        Popularity,
        'Popular' AS Popularidad_Evaluada
    FROM
        anime_filtered
    WHERE
        Popularity > 5000
    ORDER BY
        Popularity DESC
    LIMIT 5
)
UNION
(
    SELECT
        Name,
        Popularity,
        'No Popular' AS Popularidad_Evaluada
    FROM
        anime_filtered
    WHERE
        Popularity <= 5000
    ORDER BY
        Popularity ASC
    LIMIT 5
);

# Usuarios que han completado la visualización de al menos 100 animes: (HAVING #1)
SELECT
    ud.Username,
    COUNT(*) AS Numero_de_Animes_Completados
FROM
    user_score_2023 us
JOIN
    user_details_2023 ud ON us.user_id = ud.Mal_ID
WHERE
    us.anime_id IN (SELECT anime_id FROM anime_filtered WHERE Completed > 0)
GROUP BY
    ud.Username
HAVING
    COUNT(*) >= 100
ORDER BY
    Numero_de_Animes_Completados DESC;


    
# MEJORES TEMPORADAS PARA LANZAMIENTO
# Época del año más propicia para lanzar una nueva emisión: (WHERE #1)
    
SELECT
    SUBSTRING_INDEX(Premiered, ' ', 1) AS Premier_Season,
    COUNT(*) AS Total_times
FROM
    anime_filtered
WHERE
    Premiered LIKE '%spring%'
    OR Premiered LIKE '%summer%'
    OR Premiered LIKE '%fall%'
    OR Premiered LIKE '%winter%'
    GROUP BY
    Premier_Season
ORDER BY
    Total_times DESC;

# ANÁLISIS DE LAS FUENTES DESDE LAS QUE SE INSPIRA LA PELÍCULA: (JOIN + GROUP BY #5)
# Mayor rentabilidad en la producción desde la fuente original: Cantidad de usuarios que se que tuvo la película según la 
-- fuente original desde la que se hizzo, para saber de donde nacen los mayores éxitos cuando se convierten en película, 
-- fuentes más propicias:

SELECT
    af.Source,
    COUNT(DISTINCT ud.Mal_ID) AS Total_Users
FROM
    anime_filtered af
JOIN
    user_score_2023 us ON af.anime_id = us.anime_id
JOIN
    user_details_2023 ud ON us.user_id = ud.Mal_ID
GROUP BY
    af.Source
ORDER BY
    Total_Users DESC;
    

# Mas visualizaciones por fuente en la que se inspira la película, para saber de donde nacen los mayores éxitos cuando se 
-- convierten en película, para elegir las fuentes más propicias para una mayor rentabilidad en la producción: (JOIN + GROUP BY #6)

SELECT
    af.Source,
    af.Watching,
    SUM(ud.Watching) AS Total_Watching
FROM
    anime_filtered af
JOIN
    user_score_2023 us ON af.anime_id = us.anime_id
JOIN
    user_details_2023 ud ON us.user_id = ud.Mal_ID
GROUP BY
    af.Source, af.Watching
ORDER BY
    af.Watching DESC;
    
# Score de películas vs. Popularity  (ORDER BY)
-- Score:  
SELECT
    Name,
    Score
FROM
    anime_2023df
ORDER BY
    Score DESC;

-- Popularity:  (ORDER BY)
SELECT
    Name,
    Popularity
FROM
    anime_2023df
ORDER BY
    Popularity DESC

# FIDELIZACIÓN DE USUARIOS:
-- ¿Cuales son los usuarios que ven más películas? (JOIN #2)

SELECT
    ud.Username AS Username,
    COUNT(*) AS Total_Movies_Watched
FROM
    user_score_2023 us
JOIN
    user_details_2023 ud ON us.user_id = ud.Mal_ID
JOIN
    anime_filtered af ON us.anime_id = af.anime_id
GROUP BY
    ud.Username
ORDER BY
    Total_Movies_Watched DESC;

# SEGMENTACIÓN DE CLIENTES:
-- ¿Quién ve más películas más películas: hombres o mujeres? (JOIN #3)

SELECT
    d.Gender AS User_Gender,
    COUNT(*) AS View_Count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Percentage
FROM
    user_score_2023 u
JOIN
    user_details_2023 d ON u.user_id = d.Mal_ID
GROUP BY
    d.Gender;

-- ¿Qué género de películas ven cada SEXO? (WHERE + JOIN #7)

SELECT
    SUBSTRING_INDEX(af.Genres, ',', 1) AS Genre,
    ud.Gender AS Gender,
    COUNT(*) AS Total_Movies_Watched
FROM
    user_score_2023 us
JOIN
    user_details_2023 ud ON us.user_id = ud.Mal_ID
JOIN
    anime_filtered af ON us.anime_id = af.anime_id
GROUP BY
    ud.Gender, Genre
ORDER BY
    Gender, Total_Movies_Watched DESC;

		-- Sacar el TOP 5: (SUBQUERY #2)

SELECT Genre, Gender, Total_Movies_Watched
FROM (
    SELECT
        SUBSTRING_INDEX(af.Genres, ',', 1) AS Genre,
        ud.Gender AS Gender,
        COUNT(*) AS Total_Movies_Watched,
        ROW_NUMBER() OVER (PARTITION BY ud.Gender ORDER BY COUNT(*) DESC) AS rn
    FROM
        user_score_2023 us
    JOIN
        user_details_2023 ud ON us.user_id = ud.Mal_ID
    JOIN
        anime_filtered af ON us.anime_id = af.anime_id
    GROUP BY
        ud.Gender, Genre
) AS ranked
WHERE rn <= 5
ORDER BY Gender, Total_Movies_Watched DESC;

-- ¿Qué SEXO ve más películas completas? (JOIN #4)

SELECT
    ud.Gender AS Gender,
    SUM(CASE WHEN ud.Watching = 'Completed' THEN 1 ELSE 0 END) AS Total_Completed_Movies
FROM
    user_details_2023 ud
JOIN
    user_score_2023 us ON ud.Mal_ID = us.user_id
GROUP BY
    ud.Gender;

-- Relación de géneros de película POR PAISES: (JOIN #5)

SELECT
    ud.Location AS Country,
    SUBSTRING_INDEX(af.Genres, ',', 1) AS Genre,
    COUNT(*) AS Total_Movies
FROM
    user_score_2023 us
JOIN
    user_details_2023 ud ON us.user_id = ud.Mal_ID
JOIN
    anime_filtered af ON us.anime_id = af.anime_id
GROUP BY
    ud.Location, Genre
ORDER BY
    Total_Movies DESC;

# SEGMENTACIÓN EN EL MAYOR CONSUMIDOR DE MANGA
-- Películas con mejor rating en el mayor consumidor de películas: Helsinki. (WHERE #2)

SELECT
    ud.Location AS Country,
    af.Name AS Movie_Title,
    us.rating AS Rating
FROM
    user_score_2023 us
JOIN
    user_details_2023 ud ON us.user_id = ud.Mal_ID
JOIN
    anime_filtered af ON us.anime_id = af.anime_id
WHERE
    us.rating >= 7
    AND ud.Location = 'Helsinki, Finland'
ORDER BY
    Rating DESC;
    
-- Películas más populares en el mayor consumidor de películas: Helsinki. (WHERE #3)

SELECT
    ud.Location AS Country,
    af.Name AS Movie_Title,
    af.Popularity
FROM
    user_score_2023 us
JOIN
    user_details_2023 ud ON us.user_id = ud.Mal_ID
JOIN
    anime_filtered af ON us.anime_id = af.anime_id
WHERE
    ud.Location = 'Helsinki, Finland'
ORDER BY
    af.Popularity DESC;

-- Género más popular en el mayor consumidor de películas: Helsinki. (WHERE #4)

SELECT
    ud.Location AS Country,
    SUBSTRING_INDEX(af.Genres, ',', 1) AS Genre,
    COUNT(*) AS Total_Movies
FROM
    user_score_2023 us
JOIN
    user_details_2023 ud ON us.user_id = ud.Mal_ID
JOIN
    anime_filtered af ON us.anime_id = af.anime_id
WHERE
    ud.Location = 'Helsinki, Finland'
GROUP BY
    ud.Location, Genre
ORDER BY
    Total_Movies DESC;
