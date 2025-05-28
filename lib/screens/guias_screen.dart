import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../BLoC/guides/guides_bloc.dart';
import '../widgets/top_bar.dart';
import '../widgets/guide_card.dart';

class GuiasScreen extends StatefulWidget {
  const GuiasScreen({super.key});

  @override
  State<GuiasScreen> createState() => _GuiasScreenState();
}

class _GuiasScreenState extends State<GuiasScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar las guías cuando se monte el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuidesBloc>().loadGuides();
    });
  }

  String selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<GuidesBloc>(
      builder: (context, guidesBloc, child) {
        if (guidesBloc.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: TopBar(
                screenType: ScreenType.progressScreen,
                title: 'Guías',
              ),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (guidesBloc.error != null) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: TopBar(
                screenType: ScreenType.progressScreen,
                title: 'Guías',
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${guidesBloc.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => guidesBloc.loadGuides(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final categories = guidesBloc.categories;
        
        // Si no hay categoría seleccionada, seleccionar la primera
        if (selectedCategory.isEmpty && categories.isNotEmpty) {
          selectedCategory = categories.first.categoryName;
        }

        // Obtener los items de la categoría seleccionada
        final selectedItems = categories
            .where((cat) => cat.categoryName == selectedCategory)
            .expand((cat) => cat.items)
            .toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: TopBar(
              screenType: ScreenType.progressScreen,
              title: 'Guías',
            ),
          ),
          body: Column(
            children: [
              // Categorías horizontales
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: categories.map((category) {
                    final isSelected = category.categoryName == selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category.categoryName;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0E5D9E)
                              : const Color(0xFFE8F7FC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category.categoryName,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF0E5D9E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Lista de guías
              Expanded(
                child: selectedItems.isEmpty
                    ? const Center(child: Text('No hay guías disponibles'))
                    : ListView.builder(
                        itemCount: selectedItems.length,
                        itemBuilder: (context, index) {
                          final item = selectedItems[index];
                          // Formatear la fecha para mostrarla en formato DD/MM/YYYY
                          String formattedDate = item.date;
                          try {
                            if (item.date.isNotEmpty) {
                              final dateTime = DateTime.parse(item.date);
                              formattedDate = '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
                            }
                          } catch (e) {
                            print('⚠️ Error al formatear la fecha: $e');
                            // Mantener la fecha original si hay error
                          }
                          
                          return GuideCard(
                            title: item.name,
                            imageKey: item.keyMain,
                            secondaryImageKey: item.keySecondary,
                            videoKey: item.keyTertiaryVideo,
                            date: formattedDate,
                            content: item.description,
                            tag: selectedCategory,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
