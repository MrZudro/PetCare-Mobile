import '../models/cart_model.dart';
// import 'package:http/http.dart' as http; 
// import '../core/api_constants.dart';


class CartService {
  
  Future<List<CartItem>> getCartItems() async {
    // Simulación de delay de red
    await Future.delayed(const Duration(milliseconds: 800)); 

    return [
      CartItem(
        id: 'CHK-001', // SKU del SQL
        name: 'Chunky Adulto Pollo',
        description: 'Alimento premium para perros adultos sabor a pollo.',
        brand: 'Chunky',
        price: 55000.00,
        imageUrl: 'https://res.cloudinary.com/dvvhnrvav/image/upload/v1732338000/chunky_pollo_adulto.jpg',
      ),
      CartItem(
        id: 'WSK-002', // SKU del SQL
        name: 'Whiskas Carne',
        description: 'Alimento húmedo para gatos sabor carne.',
        brand: 'Whiskas',
        price: 45000.00,
        imageUrl: 'https://res.cloudinary.com/dvvhnrvav/image/upload/v1732338000/whiskas_carne.jpg',
      ),
      CartItem(
        id: 'TOY-003', // SKU del SQL
        name: 'Pelota de Goma',
        description: 'Pelota resistente para morder.',
        brand: 'PetToy',
        price: 15000.00,
        imageUrl: 'https://res.cloudinary.com/dvvhnrvav/image/upload/v1732338000/pelota_goma.jpg',
      ),
       CartItem(
        id: 'ACC-004', // SKU del SQL
        name: 'Collar Reflectivo',
        description: 'Collar ajustable con banda reflectiva para paseos nocturnos.',
        brand: 'SafePet',
        price: 25000.00,
        imageUrl: 'https://res.cloudinary.com/dvvhnrvav/image/upload/v1732338000/collar_reflectivo.jpg',
      ),
    ];
  }
}