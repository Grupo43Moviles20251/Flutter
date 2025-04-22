import 'package:flutter/material.dart';
import 'package:first_app/Models/restaurant_model.dart';

import 'package:cached_network_image/cached_network_image.dart'; 

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final bool isFavoritePage; // true si estamos en FavoritesPage
  final bool isFavorite;     // Si este restaurant está marcado ahora
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onTap;

  const RestaurantCard({
    Key? key,
    required this.restaurant,
    this.isFavoritePage = false,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Lleva al detalle, o null
      child: Card(
        color: isFavoritePage ? Color(0xFF2A9D8F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) Imagen con CachedNetworkImage
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: CachedNetworkImage(
                imageUrl: restaurant.imageUrl,  // URL de la imagen
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: CircularProgressIndicator()), // Imagen mientras se carga
                errorWidget: (context, url, error) => Icon(Icons.error), // Imagen si hay error
              ),
            ),

            // 2) Título + Corazón
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // El título
                  Expanded(
                    child: Text(
                      restaurant.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isFavoritePage ? Colors.white : Colors.black,
                      ),
                    ),
                  ),

                  // El corazón, alineado a la derecha
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 26,
                      color: isFavorite
                          ? Colors.red
                          : (isFavoritePage ? Colors.white : Colors.grey),
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ],
              ),
            ),

            // 3) Resto del cuerpo: Subtítulo, rating, precios
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Surprise bag",
                    style: TextStyle(
                      color: isFavoritePage ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.star,
                          color: isFavoritePage ? Colors.yellow : Colors.amber,
                          size: 18),
                      Text(
                        "${restaurant.rating}",
                        style: TextStyle(
                          fontSize: 14,
                          color: isFavoritePage ? Colors.white : Colors.black,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "\$${restaurant.products[0].originalPrice}",
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: isFavoritePage ? Colors.white70 : Colors.grey,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "\$${restaurant.products[0].discountPrice}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isFavoritePage
                              ? Colors.white
                              : Color(0xFF2A9D8F),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
