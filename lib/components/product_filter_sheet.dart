import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';

class ProductFilterSheet extends StatefulWidget {
  final Map<String, String?> activeFilters;
  final Function(String, String?) onFilterChange;
  final VoidCallback onClearFilters;
  final Map<String, List<String>> availableFilters;
  final String? sortBy;
  final Function(String) onSortChange;

  const ProductFilterSheet({
    Key? key,
    required this.activeFilters,
    required this.onFilterChange,
    required this.onClearFilters,
    required this.availableFilters,
    this.sortBy = 'default',
    required this.onSortChange,
  }) : super(key: key);

  @override
  State<ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<ProductFilterSheet> {
  late Map<String, String?> localFilters;

  @override
  void initState() {
    super.initState();
    localFilters = Map.from(widget.activeFilters);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filtros',
                          style: TextStyles.titleText.copyWith(
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            localFilters = Map.from(widget.activeFilters);
                            setState(() {});
                          },
                        child: Text(
                          'Limpiar',
                          style: TextStyles.bodyTextBlack.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 0),

              // Ordenamiento
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ordenar por',
                      style: TextStyles.bodyTextBlack.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SortOption(
                          label: 'Recomendados',
                          value: 'default',
                          isSelected: widget.sortBy == 'default',
                          onTap: () => widget.onSortChange('default'),
                        ),
                        _SortOption(
                          label: 'Menor Precio',
                          value: 'price-asc',
                          isSelected: widget.sortBy == 'price-asc',
                          onTap: () => widget.onSortChange('price-asc'),
                        ),
                        _SortOption(
                          label: 'Mayor Precio',
                          value: 'price-desc',
                          isSelected: widget.sortBy == 'price-desc',
                          onTap: () => widget.onSortChange('price-desc'),
                        ),
                        _SortOption(
                          label: 'A-Z',
                          value: 'name-asc',
                          isSelected: widget.sortBy == 'name-asc',
                          onTap: () => widget.onSortChange('name-asc'),
                        ),
                        _SortOption(
                          label: 'Z-A',
                          value: 'name-desc',
                          isSelected: widget.sortBy == 'name-desc',
                          onTap: () => widget.onSortChange('name-desc'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 0),

              // Filtros de categoría
              if (widget.availableFilters.containsKey('category') &&
                  widget.availableFilters['category']!.isNotEmpty)
                _FilterSection(
                  title: 'Categoría',
                  options: widget.availableFilters['category'] ?? [],
                  selectedValue: localFilters['category'],
                  onSelect: (value) {
                    setState(() {
                      localFilters['category'] = value;
                      localFilters['subcategory'] = null;
                    });
                  },
                ),

              // Filtros de subcategoría
              if (widget.availableFilters.containsKey('subcategory') &&
                  widget.availableFilters['subcategory']!.isNotEmpty)
                _FilterSection(
                  title: 'Subcategoría',
                  options: widget.availableFilters['subcategory'] ?? [],
                  selectedValue: localFilters['subcategory'],
                  onSelect: (value) {
                    setState(() {
                      localFilters['subcategory'] = value;
                    });
                  },
                ),

              // Filtros de marca
              if (widget.availableFilters.containsKey('brand') &&
                  widget.availableFilters['brand']!.isNotEmpty)
                _FilterSection(
                  title: 'Marca',
                  options: widget.availableFilters['brand'] ?? [],
                  selectedValue: localFilters['brand'],
                  onSelect: (value) {
                    setState(() {
                      localFilters['brand'] = value;
                    });
                  },
                ),

              // Botones de acción
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          localFilters = Map.from(widget.activeFilters);
                          setState(() {});
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primary,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Limpiar filtros',
                          style: TextStyles.bodyTextBlack.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          for (var entry in localFilters.entries) {
                            if (entry.value != widget.activeFilters[entry.key]) {
                              widget.onFilterChange(entry.key, entry.value);
                            }
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Aplicar',
                          style: TextStyles.bodyTextBlack.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selectedValue;
  final Function(String?) onSelect;

  const _FilterSection({
    required this.title,
    required this.options,
    this.selectedValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            title,
            style: TextStyles.bodyTextBlack.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (int i = 0; i < options.length; i++)
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (selectedValue == options[i]) {
                          onSelect(null);
                        } else {
                          onSelect(options[i]);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedValue == options[i]
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: selectedValue == options[i]
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                options[i],
                                style: TextStyles.bodyTextBlack.copyWith(
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i < options.length - 1)
                      Divider(
                        height: 0,
                        color: Colors.grey.shade200,
                      ),
                  ],
                ),
            ],
          ),
        ),
        const Divider(height: 0),
      ],
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Text(
          label,
          style: TextStyles.bodyTextBlack.copyWith(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
