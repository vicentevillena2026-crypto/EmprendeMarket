
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final router = Router();

  final productos = [
    {
      'id': 0,
      'nombre': 'Polera algodón pima',
      'precio': 45,
      'imagen': 'images/product_0.jpg'
    },
    {
      'id': 1,
      'nombre': 'Casaca jean artesanal',
      'precio': 120,
      'imagen': 'images/product_1.jpg'
    },
    {
      'id': 2,
      'nombre': 'Collar de plata',
      'precio': 65,
      'imagen': 'images/product_2.jpg'
    },
    {
      'id': 3,
      'nombre': 'Mochila tejida',
      'precio': 90,
      'imagen': 'images/product_3.jpg'
    },
    {
      'id': 4,
      'nombre': 'Audífonos Bluetooth',
      'precio': 79,
      'imagen': 'images/product_4.jpg'
    },
    {
      'id': 5,
      'nombre': 'Vela aromática',
      'precio': 30,
      'imagen': 'images/product_5.jpg'
    }
  ];

  router.get('/productos', (Request request) {
    return Response.ok(
      jsonEncode(productos),
      headers: {
        'Content-Type': 'application/json; charset=utf-8'
      },
    );
  });

  final server = await shelf_io.serve(
    router.call,
    '0.0.0.0',
    8080,
  );

  print('API iniciada en el puerto ${server.port}');
}
