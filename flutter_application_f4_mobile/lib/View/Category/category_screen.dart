import 'package:flutter/material.dart';
import 'package:flutter_application_f4_mobile/Controller/brandsController.dart';
import 'package:flutter_application_f4_mobile/Model/brandsModel.dart';
import 'product_by_category_screen.dart';

class CategoryScreen extends StatefulWidget{
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}
class _CategoryScreenState extends State<CategoryScreen> {

  late Future<List<BrandsModel>> _futureBrands;

  @override
  void initState() {
    getBrands();
    super.initState();
  }

  Future<void> getBrands()async{
    if(mounted){
      _futureBrands = BrandsController.getAllBrands();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Categories",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body:
      FutureBuilder<List<BrandsModel>>(
        future: _futureBrands, 
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Lỗi: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Không có sản phẩm nào"));
            }
          final List<BrandsModel>? brands = snapshot.data;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: brands!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final cat = brands[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductByCategoryScreen(
                          category_id: cat.id,
                          nameBrands: cat.name, // ✅ GIỜ KHÔNG CÒN NULL
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ===== VÒNG TRÒN NGOÀI =====
                        Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFF5F5F5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Image.network(
                              headers: const {"ngrok-skip-browser-warning": "true",},
                              cat.image_url,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          cat.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      )
    );
  }
}
