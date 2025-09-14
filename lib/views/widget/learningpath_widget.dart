import 'package:autism_fyp/assets/local_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/items_controller.dart';

class LearningWidget extends StatelessWidget {
  final List<Map<String, dynamic>>? modules; // Accept modules as parameter
  final LearningItemController controller = Get.put(LearningItemController());

  LearningWidget({super.key, this.modules});

  @override
  Widget build(BuildContext context) {
    // If modules are provided, use them. Otherwise, fetch from controller
    if (modules != null) {
      return _buildGridWithModules(modules!);
    } else {
      controller.fetchLearningItems(); 
      return Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.items.isEmpty) {
          return const Center(child: Text("No learning items found."));
        }

        return _buildGridWithControllerItems();
      });
    }
  }

  Widget _buildGridWithModules(List<Map<String, dynamic>> modules) {
    if (modules.isEmpty) {
      return const Center(child: Text("No modules found."));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final module = modules[index];
        final title = module['title'].toString();
        final imagePath = getImageForTitle(title); // Use your image mapping function
        
        return GestureDetector(
          onTap: () {
            navigateToItemScreen(title, context); // navigate on tap
          },
          child: Container(
            decoration: BoxDecoration(
              color: containerColors[index % containerColors.length],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(imagePath, width: 80, height: 80),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridWithControllerItems() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final item = controller.items[index];
        return GestureDetector(
          onTap: () {
            navigateToItemScreen(item.title, context); // navigate on tap
          },
          child: Container(
            decoration: BoxDecoration(
              color: containerColors[index % containerColors.length],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(item.imagePath, width: 80, height: 80),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add your container colors array
  final List<Color> containerColors = [
    const Color(0xFFE3F2FD),
    const Color(0xFFE8F5E9),
    const Color(0xFFFFEBEE),
    const Color(0xFFF3E5F5),
    const Color(0xFFE0F7FA),
    const Color(0xFFFFF8E1),
    const Color(0xFFE8EAF6),
    const Color(0xFFF1F8E9),
  ];
}