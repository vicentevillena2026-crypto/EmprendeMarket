import 'package:flutter/material.dart';

class ListProducsScreen extends StatelessWidget {
  const ListProducsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productos = [
      {
        'nombre': 'Polo Oversize',
        'precio': 'S/ 59.90',
        'icono': Icons.checkroom,
        'color': Colors.orange.shade100,
      },
      {
        'nombre': 'Pantalón Jean',
        'precio': 'S/ 99.90',
        'icono': Icons.checkroom,
        'color': Colors.blue.shade100,
      },
      {
        'nombre': 'Casaca Negra',
        'precio': 'S/ 149.90',
        'icono': Icons.checkroom,
        'color': Colors.grey.shade300,
      },
      {
        'nombre': 'Polo Blanco',
        'precio': 'S/ 45.90',
        'icono': Icons.checkroom,
        'color': Colors.green.shade100,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ModaStyle'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Carrito de compras')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Bienvenido a ModaStyle',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Encuentra la mejor ropa para ti',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            'Productos destacados',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: productos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final producto = productos[index];

              return Card(
                elevation: 3,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: producto['color'] as Color,
                        child: Icon(
                          producto['icono'] as IconData,
                          size: 75,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            producto['nombre'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(producto['precio'] as String),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${producto['nombre']} seleccionado',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Agregar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
